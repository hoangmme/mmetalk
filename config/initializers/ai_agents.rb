# frozen_string_literal: true

require 'agents'

Rails.application.config.after_initialize do
  Llm::Config.configure_ai_agents!
end
