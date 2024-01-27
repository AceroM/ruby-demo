module Synctera
  class Disclosures
    def initialize(client:, user:)
      @client = client
      @user = user
    end

    def get(id)
      @client.get("/v0/disclosures", { id: })
    end

    def list(paginate: false, limit: nil, type: nil)
      data = []
      if @user && type.nil?
        raise ArgumentError, "Must specify type when user is present"
      else
        next_page_token = nil
        params = { page_token: next_page_token, limit: limit }
        if type == "business"
          @client.require_business
          params[:business_id] = @user.business_id
        end
        if type == "person"
          @client.require_person
          params[:person_id] = @user.person_id
        end
        loop do
          response = @client.get("/v0/disclosures", params.compact)
          data += response.dig("disclosures")
          next_page_token = response.dig("next_page_token")
          break if next_page_token.nil? || !paginate
        end
        data
      end
    end

    def accept_person_disclosure(type)
      @client.require_person
      @client.post("/v0/disclosures", {
        person_id: @user.person_id,
        type: type,
        version: "1.0",
        event_type: "ACKNOWLEDGED",
        disclosure_date: Time.now.utc.iso8601
      }.to_json)
    end

    def self.sync_all(user)
      client = Synctera::Client.new(user: user)
      disclosures = user.disclosures.all
      person_disclosures = client.disclosures.list(type: "person")
      business_disclosures = client.disclosures.list(type: "business")
      [person_disclosures, business_disclosures].each do |platform_disclosures|
        disclosures_to_insert = platform_disclosures - disclosures
        if disclosures_to_insert.any?
          attributes = get_attributes(user)
          user.disclosures.create(disclosures_to_insert.map(&attributes))
        end
        disclosures_to_delete = disclosures.filter do |disclosure|
          platform_disclosures.none? { |d| d["id"] == disclosure.platform_id }
        end
        if disclosures_to_delete.any?
          user.disclosures.where(platform_id: disclosures_to_delete.map(&:platform_id)).delete_all
        end
        disclosures_to_upsert = platform_disclosures.filter do |disclosure|
          disclosures.any? { |d| d.platform_id == disclosure["id"] && d.platform_last_updated_at != disclosure["last_updated_time"] }
        end
        if disclosures_to_upsert.any?
          attributes = get_attributes(user)
          user.disclosures.upsert_all(disclosures_to_upsert.map(&attributes), unique_by: :platform_id)
        end
      end
    end

    def self.sync(user:, disclosure_id:)
      client = Synctera::Client.new(user: user)
      disclosure = client.get(id)
    end

    private

    def self.excluded_keys
      %w[id type event_type last_updated_time person_id business_id]
    end

    def self.get_attributes(user)
      lambda do |disclosure|
        {
          platform_id: disclosure["id"],
          platform_type: disclosure["type"],
          event_type: disclosure["event_type"],
          platform_last_updated_at: disclosure["last_updated_time"],
          synctera_person_id: disclosure["person_id"] == user.person_id ? user.person_id : nil,
          synctera_business_id: disclosure["business_id"] == user.business_id ? user.business_id : nil,
          data: disclosure.except(*excluded_keys)
        }.compact
      end
    end
  end
end
