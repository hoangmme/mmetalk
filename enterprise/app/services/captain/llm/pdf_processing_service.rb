class Captain::Llm::PdfProcessingService
  def initialize(document)
    @document = document
  end

  def process
    return if document.content.present?
    return unless document.pdf_file.attached?

    extracted_text = extract_local_pdf_text
    raise CustomExceptions::Pdf::UploadError, I18n.t('captain.documents.pdf_upload_failed') if extracted_text.blank?

    document.update!(content: extracted_text[0...195_000])
  end

  private

  attr_reader :document

  def extract_local_pdf_text
    document.pdf_file.blob.open do |blob_file|
      Captain::Llm::LocalRagService.extract_pdf_text(blob_file)
    end
  rescue StandardError => e
    Rails.logger.error("[PdfProcessingService] Local PDF extraction failed: #{e.message}")
    nil
  end
end
