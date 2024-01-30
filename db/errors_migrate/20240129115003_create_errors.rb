class CreateErrors < ActiveRecord::Migration[7.1]
  def change
    create_table :errors do |t|
      t.string :exception_class, null: false
      t.string :message, null: false
      t.string :severity, null: false
      t.string :source
      t.datetime :resolved_at, index: true

      t.timestamps

      t.index [:exception_class, :message, :severity, :source], unique: true, name: "solid_error_uniqueness_index"
    end
  end
end
