class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :name
      t.boolean :suspended
      t.integer :admin_clearance, default: 0
      t.string :timezone
      t.date :signed_tos_on

      t.timestamps
    end
  end
end
