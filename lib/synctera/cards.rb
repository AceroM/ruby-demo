module Synctera
  class Cards
    attr_reader :client, :user

    def initialize(client:, user:)
      @client = client
      @user = user
    end

    def list(params = {})
      client.get("/v0/cards?limit=100")
    end
  end
end
