module Synctera
  class Disclosures
    def initialize(client:, user:)
      @client = client
      @user = user
    end

    def list(paginate: false, limit: nil)
      data = []
      next_page_token = nil

      loop do
        response = @client.get("/v0/disclosures", {
          business_id: @user&.synctera_business&.platform_id,
          person_id: @user&.synctera_person&.platform_id,
          acknowledging_person_id: @user&.synctera_person&.platform_id,
          page_token: next_page_token,
          limit: limit
        }.compact)
        data += response.dig("disclosures")
        next_page_token = response.dig("next_page_token")
        break if next_page_token.nil? || !paginate
      end

      data
    end

    def accept_person_disclosure(type)
      @client.post("/v0/disclosures", {
        person_id: @user.synctera_person.platform_id,
        type: type,
        version: "1.0",
        event_type: "ACKNOWLEDGED",
        disclosure_date: Time.now.utc.iso8601
      }.to_json)
    end

    def self.sync_all(user)
      puts "hello"
      client = Synctera::Client.new(user: user)
      disclosures = client.disclosures.list
      puts disclosures
      # user.synctera_disclosures.upsert_all disclosures.map do |d|
      #   {
      #     platform_id: d["id"],
      #     disclosure_type: d["type"],
      #     event_type: d["event_type"],
      #     synctera_person: user.synctera_person,
      #     synctera_business: user.synctera_business,
      #     data: d.slice("creation_time", "disclosure_date", "last_updated_time")
      #   }
      # end
    end
  end
end
