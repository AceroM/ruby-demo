class CreateSyncteraAccounts < ActiveRecord::Migration[7.1]
  def change
    create_table :synctera_accounts do |t|
      t.string :platform_id
      t.datetime :platform_last_updated_at
      t.string :name
      t.jsonb :data
      t.references :user, null: false, foreign_key: true
      t.references :synctera_business, null: false, foreign_key: true
      t.references :synctera_person, null: false, foreign_key: true

      t.timestamps
    end
    
    add_index :synctera_accounts, :platform_id, unique: true
  end
end
