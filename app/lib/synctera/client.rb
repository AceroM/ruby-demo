module Synctera
  class Client
    include Http

    CONFIG_KEYS = %i[api_key base_url user]
    attr_reader *CONFIG_KEYS

    def initialize(config = {})
      CONFIG_KEYS.each do |key|
        instance_variable_set(:"@#{key}", config[key] || Synctera.configuration.send(key))
      end
    end

    def cards
      @cards ||= Cards.new(client: self, user: @user)
    end

    def persons
      @persons ||= Persons.new(client: self, user: @user)
    end
  end
end
