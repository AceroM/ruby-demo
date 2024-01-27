module Synctera
  class Persons
    def initialize(client:, user:)
      @client = client
      @user = user

      unless @user
        raise ConfigurationError, "User is required"
      end
    end

    def get
      @client.require_person
      @client.get("/v0/persons/#{@user.person_id}")
    end

    def create
      @client.post("/v0/persons", {
        is_customer: true,
        status: "PROSPECT"
      }.to_json)
    end

    def save_info(params)
      @client.require_person
      @client.patch("/v0/persons/#{@user.person_id}", {
        email: @user.email,
        phone_number: @user.onboarding_flow.phone_number,
        first_name: params.first_name,
        last_name: params.last_name,
        dob: params.dob,
        ssn: params.ssn,
        is_customer: true
      }.to_json)
    end

    def activate
      @client.require_person
      @client.patch("/v0/persons/#{@user.person_id}", { status: "ACTIVE" }.to_json)
    end

    def save_address(params)
      @client.require_person
      @client.patch("/v0/persons/#{@user.person_id}", {
        legal_address: {
          address_line_1: params.address_line_one,
          address_line_2: params.address_line_two || "",
          city: params.city,
          state: params.state,
          country_code: "US",
          postal_code: params.postal_code
        }
      }.to_json)
    end

    def self.sync(user, force_update = false)
      client = Synctera::Client.new(user: user)
      synctera_person = client.persons.get
      unless synctera_person
        puts "Synctera person not found for user #{user.email}"
        return
      end
      if (user.synctera_person.platform_last_updated_at != synctera_person["last_updated_time"]) || force_update
        puts "Person updated for user #{user.email}"
        user.synctera_person.update(platform_last_updated_at: synctera_person["last_updated_time"], data: synctera_person.except(*excluded_keys))
      else
        puts "No changes found for user #{user.email}"
      end
    end

    private

    def self.excluded_keys
      %w[id last_updated_time ssn dob tenant ssn_source personal_ids legal_address]
    end
  end
end
