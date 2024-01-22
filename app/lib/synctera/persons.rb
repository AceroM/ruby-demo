module Synctera
  class Persons
    def initialize(client:, user:)
      @client = client
      @user = user

      unless @user
        raise ConfigurationError, "User is required"
      end
    end

    def create
      @client.post("/v0/persons", {
        is_customer: true,
        status: "PROSPECT"
      }.to_json)
    end
  end
end
