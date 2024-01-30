class CreateErrorOccurrences < ActiveRecord::Migration[7.1]
  def change
    create_table :error_occurrences do |t|
      t.belongs_to :error, null: false, foreign_key: true
      t.text :backtrace
      t.json :context

      t.timestamps
    end
  end
end
