class CreateSyncteraDisclosures < ActiveRecord::Migration[7.1]
  def change
    create_table :synctera_disclosures do |t|
      t.string :platform_id
      t.string :platform_type
      t.string :event_type
      t.jsonb :data
      t.timestamp :platform_last_updated_at
      t.references :user, null: false, foreign_key: true
      t.references :synctera_person, foreign_key: true
      t.references :synctera_business, foreign_key: true

      t.timestamps
    end

    add_index :synctera_disclosures, :platform_id, unique: true
  end
end
