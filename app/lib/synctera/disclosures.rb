module Synctera
  class Disclosures
    def initialize(client:, user:)
      @client = client
      @user = user
    end

    def list(paginate: false, limit: nil, type: nil)
      data = []
      if @user && type.nil?
        raise ArgumentError, "Must specify type when user is present"
      else
        next_page_token = nil
        params = { page_token: next_page_token, limit: limit }
        params[:business_id] = @user.business_id if type == "business"
        params[:person_id] = @user.person_id if type == "person"
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
      @client.post("/v0/disclosures", {
        person_id: @user.synctera_person.platform_id,
        type: type,
        version: "1.0",
        event_type: "ACKNOWLEDGED",
        disclosure_date: Time.now.utc.iso8601
      }.to_json)
    end

    def self.sync_all(user)
      client = Synctera::Client.new(user: user)
      disclosures = user.disclosures
      person_disclosures = client.disclosures.list(type: "person")
      business_disclosures = client.disclosures.list(type: "business")
      [person_disclosures, business_disclosures].each do |platform_disclosures|
        disclosures_to_upsert = platform_disclosures - disclosures
        disclosures_to_delete = disclosures.filter do |disclosure|
          platform_disclosures.none? { |d| d["id"] == disclosure.platform_id }
        end
        if disclosures_to_delete.any?
          user.disclosures.where(platform_id: disclosures_to_delete.map(&:platform_id)).delete_all
        end
        changed_disclosures = platform_disclosures.filter do |disclosure|
          disclosures.any? { |d| d.platform_id == disclosure["id"] && d.platform_last_updated_at != disclosure["last_updated_time"] }
        end
        if changed_disclosures.any?
          disclosures_to_upsert.concat(changed_disclosures)
        end
        if disclosures_to_upsert.any?
          user.disclosures.upsert_all(
            disclosures_to_upsert.map do |disclosure|
              attributes(disclosure).merge({
                synctera_person_id: disclosure["person_id"] ? user.synctera_person.id : nil,
                synctera_business_id: disclosure["business_id"] ? user.synctera_business.id : nil
              }).compact
            end,
            unique_by: :platform_id
          )
        end
      end
    end

    private

    def self.excluded_keys
      %w[id type event_type last_updated_time person_id business_id]
    end

    def self.attributes(disclosure)
      {
        platform_id: disclosure["id"],
        platform_type: disclosure["type"],
        event_type: disclosure["event_type"],
        platform_last_updated_at: disclosure["last_updated_time"],
        data: disclosure.except(*excluded_keys)
      }
    end
  end
end
