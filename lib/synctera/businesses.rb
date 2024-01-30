module Synctera
  class Businesses
    attr_reader :client, :user

    def initialize(client:, user:)
      @client = client
      @user = user

      unless user
        raise ConfigurationError, "User is required"
      end
    end

    def create
      client.post("/v0/businesses", {
        is_customer: true,
        status: "PROSPECT",
        entity_name: user.email
      }.to_json)
    end
  end
end
