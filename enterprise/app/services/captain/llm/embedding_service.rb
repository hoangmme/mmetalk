class Captain::Llm::EmbeddingService
  include Integrations::LlmInstrumentation

  class EmbeddingsError < StandardError; end

  def initialize(account_id: nil)
    Llm::Config.initialize!
    @account_id = account_id
    @embedding_model = InstallationConfig.find_by(name: 'CAPTAIN_EMBEDDING_MODEL')&.value.presence || LlmConstants::DEFAULT_EMBEDDING_MODEL
  end

  def self.embedding_model
    InstallationConfig.find_by(name: 'CAPTAIN_EMBEDDING_MODEL')&.value.presence || LlmConstants::DEFAULT_EMBEDDING_MODEL
  end

  def get_embedding(content, model: @embedding_model)
    return [] if content.blank?

    instrument_embedding_call(instrumentation_params(content, model)) do
      RubyLLM.embed(content, model: model).vectors
    end
  rescue StandardError => e
    Rails.logger.warn "Embedding API Error (#{e.class}: #{e.message}), falling back to local hash embedding"
    generate_hash_embedding(content)
  end

  private

  def generate_hash_embedding(text, dim = 1536)
    require 'digest'
    vector = Array.new(dim, 0.0)
    tokens = text.to_s.downcase.scan(/[\wÀ-ỹ]+/)
    return vector if tokens.empty?

    tokens.each do |token|
      digest = Digest::SHA256.digest(token)
      index = digest[0, 4].unpack1('V') % dim
      sign = (digest[4].ord % 2).zero? ? 1.0 : -1.0
      vector[index] += sign
    end

    norm = Math.sqrt(vector.sum { |v| v**2 })
    return vector if norm.zero?

    vector.map { |v| (v / norm).round(6) }
  end

  def instrumentation_params(content, model)
    {
      span_name: 'llm.captain.embedding',
      model: model,
      input: content,
      feature_name: 'embedding',
      account_id: @account_id
    }
  end
end
