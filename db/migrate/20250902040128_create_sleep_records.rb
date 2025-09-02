class CreateSleepRecords < ActiveRecord::Migration[8.0]
  def change
    create_table :sleep_records do |t|
      t.references :user, null: false
      t.date :date, null: false
      t.integer :score
      t.jsonb :raw_data

      t.timestamps
    end
  end
end
