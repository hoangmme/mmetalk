require 'ruby_llm'

module Llm::Config
  DEFAULT_MODEL = 'gpt-4.1-mini'.freeze

  class << self
    def initialized?
      @initialized ||= false
    end

    def initialize!(force: false)
      return if @initialized && !force

      configure_ruby_llm
      configure_ai_agents!
      @initialized = true
    end

    def reset!
      @initialized = false
    end

    def configure_ai_agents!
      return unless defined?(Agents)

      api_key = system_api_key
      model = InstallationConfig.find_by(name: 'CAPTAIN_OPEN_AI_MODEL')&.value.presence || DEFAULT_MODEL
      api_endpoint = openai_endpoint

      return if api_key.blank?

      Agents.configure do |config|
        config.openai_api_key = api_key
        if api_endpoint.present?
          base = api_endpoint.chomp('/').sub(/\/v1$/, '')
          config.openai_api_base = "#{base}/v1"
        end
        config.default_model = model
        config.debug = false
      end
    rescue StandardError => e
      Rails.logger.error "Failed to configure AI Agents SDK: #{e.message}"
    end

    def with_api_key(api_key, api_base: nil)
      initialize!
      context = RubyLLM.context do |config|
        config.openai_api_key = api_key
        config.openai_api_base = api_base
      end

      yield context
    end

    private

    def configure_ruby_llm
      RubyLLM.configure do |config|
        config.openai_api_key = system_api_key if system_api_key.present?
        if openai_endpoint.present?
          base = openai_endpoint.chomp('/').sub(/\/v1$/, '')
          config.openai_api_base = "#{base}/v1"
        end
        config.model_registry_file = Rails.root.join('config/llm_models.json').to_s
        config.logger = Rails.logger
      end
    end

    def system_api_key
      InstallationConfig.find_by(name: 'CAPTAIN_OPEN_AI_API_KEY')&.value
    end

    def openai_endpoint
      InstallationConfig.find_by(name: 'CAPTAIN_OPEN_AI_ENDPOINT')&.value
    end
  end
end
