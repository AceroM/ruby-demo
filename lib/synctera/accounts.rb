module Synctera
  class Accounts
    attr_reader :client, :user

    def initialize(client:, user:)
      @client = client
      @user = user

      unless user.respond_to?(:business_id)
        raise ConfigurationError, "Invalid user"
      end
    end

    def create
      client.post("/v0/accounts", {
        account_template_id: Rails.application.credentials.dig(:synctera, :account_template_id),
        relationships: [
          {
            business_id: user.business_id,
            relationship_type: "ACCOUNT_HOLDER"
          },
          {
            person_id: user.person_id,
            relationship_type: "AUTHORIZED_SIGNER"
          }
        ]
      }.to_json)
    end
  end
end
