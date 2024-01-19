class CreateUserOnboardings < ActiveRecord::Migration[7.1]
  def change
    create_table :user_onboardings do |t|
      t.boolean :accepted_disclosures
      t.string :phone_number
      t.boolean :person_organization_linked
      t.boolean :person_address_saved
      t.boolean :business_info_saved
      t.boolean :business_info_collected
      t.string :kyc_code
      t.string :kyb_code
      t.boolean :virtual_account_created
      t.datetime :plaid_connection_time
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
