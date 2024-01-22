class CreateSyncteraPeople < ActiveRecord::Migration[7.1]
  def change
    create_table :synctera_people do |t|
      t.string :platform_id
      t.jsonb :data
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end