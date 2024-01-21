module Synctera
  class Persons
    def initialize(client:, user:)
      @client = client
      @user = user
    end

    def create
      puts @user
      # @client.post("/v0/persons", {
      #   is_customer: true,
      #   status: "PROSPECT"
      # }.to_json)
    end
  end
end
