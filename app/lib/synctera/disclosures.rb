module Synctera
  class Disclosures
    def initialize(client:, user:)
      @client = client
      @user = user
      # unless @user.synctera_person.present?
      #   raise ConfigurationError, "Synctera person not found for user"
      # end
    end

    def list(paginate: false, limit: nil)
      data = []
      next_page_token = nil

      loop do
        response = @client.get("/v0/disclosures", { page_token: next_page_token, limit: }.compact)
        data += response.dig("disclosures")
        next_page_token = response.dig("next_page_token")
        break if next_page_token.nil? || !paginate
      end

      data
    end

    def self.sync_all(user)
      client = Client.new(user: user)
      disclosures = client.disclosures.list(paginate: true)
      user.synctera_disclosures.upsert_all disclosures.map do |d|
        {
          platform_id: d["id"],
          disclosure_type: d["type"],
          event_type: d["event_type"],
          synctera_person: user.synctera_person,
          synctera_business: user.synctera_business,
          data: d.slice("creation_time", "disclosure_date", "last_updated_time")
        }
      end
    end
  end
end
