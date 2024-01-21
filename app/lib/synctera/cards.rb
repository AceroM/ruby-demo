module Synctera
  class Cards
    def initialize(client:, user:)
      @client = client
      @user = user
    end

    def list(params = {})
      @client.get("/v0/cards?limit=100")
    end
  end
end
