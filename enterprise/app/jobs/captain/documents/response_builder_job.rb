class Captain::Documents::ResponseBuilderJob < ApplicationJob
  queue_as :low

  def perform(document, options = {})
    reset_previous_responses(document)

    faqs = generate_faqs(document, options)
    create_responses_from_faqs(faqs, document)
  end

  private

  def generate_faqs(document, options)
    content = document.content.to_s
    return [] if content.blank?

    if should_use_pagination?(document)
      generate_paginated_faqs(document, options)
    elsif document.pdf_document? || content.length > 3000
      generate_local_rag_faqs(document)
    else
      generate_standard_faqs(document)
    end
  end

  def generate_local_rag_faqs(document)
    chunks = Captain::Llm::LocalRagService.chunk_text(document.content)
    faqs = []
    chunks.each_with_index do |chunk, index|
      chunk_doc = document.dup
      chunk_doc.content = chunk
      generated = Captain::Llm::FaqGeneratorService.new(document: chunk_doc).generate
      if generated.present?
        faqs.concat(generated)
      else
        title = document.name.presence || document.external_link
        faqs << {
          'question' => "#{title} (Phần #{index + 1})",
          'answer' => chunk
        }
      end
    end
    faqs
  rescue StandardError => e
    Rails.logger.error("[ResponseBuilderJob] Local RAG chunking error: #{e.message}")
    generate_standard_faqs(document)
  end

  def generate_paginated_faqs(document, options)
    service = build_paginated_service(document, options)
    faqs = service.generate
    store_paginated_metadata(document, service)
    faqs
  end

  def generate_standard_faqs(document)
    faqs = Captain::Llm::FaqGeneratorService.new(document: document).generate
    if faqs.blank? && document.content.present?
      title = document.name.presence || document.external_link
      faqs = [{ 'question' => title, 'answer' => document.content }]
    end
    faqs
  rescue StandardError => e
    Rails.logger.error("[ResponseBuilderJob] Standard FAQ generation failed: #{e.message}")
    return [] if document.content.blank?

    title = document.name.presence || document.external_link
    [{ 'question' => title, 'answer' => document.content }]
  end

  def build_paginated_service(document, options)
    Captain::Llm::PaginatedFaqGeneratorService.new(
      document,
      pages_per_chunk: options[:pages_per_chunk],
      max_pages: options[:max_pages],
      language: document.account.locale_english_name
    )
  end

  def store_paginated_metadata(document, service)
    document.update!(
      metadata: (document.metadata || {}).merge(
        'faq_generation' => {
          'method' => 'paginated',
          'pages_processed' => service.total_pages_processed,
          'iterations' => service.iterations_completed,
          'timestamp' => Time.current.iso8601
        }
      )
    )
  end

  def create_responses_from_faqs(faqs, document)
    faqs.each { |faq| create_response(faq, document) }
  end

  def should_use_pagination?(document)
    # Auto-detect when to use pagination
    # For now, use pagination for PDFs with OpenAI file ID
    document.pdf_document? && document.openai_file_id.present?
  end

  def reset_previous_responses(response_document)
    response_document.responses.where(edited: false).destroy_all
  end

  def create_response(faq, document)
    document.responses.create!(
      question: faq['question'],
      answer: faq['answer'],
      assistant: document.assistant,
      documentable: document
    )
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error I18n.t('captain.documents.response_creation_error', error: e.message)
  end
end
