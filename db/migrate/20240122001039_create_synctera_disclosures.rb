class CreateSyncteraDisclosures < ActiveRecord::Migration[7.1]
  def change
    create_table :synctera_disclosures do |t|
      t.string :platform_id
      t.string :disclosure_type
      t.string :event_type
      t.jsonb :data
      t.references :user, null: false, foreign_key: true
      t.references :synctera_person, null: false, foreign_key: true
      t.references :synctera_business, null: false, foreign_key: true

      t.timestamps
    end
  end
end
