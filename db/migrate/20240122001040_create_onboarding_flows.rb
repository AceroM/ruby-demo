class CreateOnboardingFlows < ActiveRecord::Migration[7.1]
  def change
    create_table :onboarding_flows do |t|
      t.datetime :accepted_disclosures
      t.string :phone_number
      t.datetime :phone_verified
      t.datetime :person_organization_linked
      t.datetime :person_address_saved
      t.datetime :business_info_saved
      t.datetime :business_info_collected
      t.string :kyc_code
      t.datetime :kyc_verified
      t.string :kyb_code
      t.datetime :kyb_verified
      t.datetime :virtual_account_created
      t.datetime :plaid_connection_time
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
