Dir[File.join(__dir__, "synctera", "*.rb")].each do |file|
  require_relative file
end

module Synctera
  class SyncteraError < StandardError; end

  class ConfigurationError < StandardError; end

  class MiddlewareErrors < Faraday::Middleware
    def call(env)
      @app.call(env)
    rescue Faraday::Error => e
      raise e unless e.response.is_a?(Hash)
      puts e.response[:body]
      raise SyncteraError, e.response[:body]
    end
  end

  class Configuration
    attr_accessor :api_key, :base_url, :user

    API_KEY = Rails.application.credentials.dig(:synctera, :api_key).freeze
    BASE_URL = Rails.application.credentials.dig(:synctera, :base_url).freeze

    def initialize
      @api_key = API_KEY
      @base_url = BASE_URL
      @user = nil
    end
  end

  class << self
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end
end
