class CreateDailyReflections < ActiveRecord::Migration[8.0]
  def change
    create_table :daily_reflections do |t|
      t.references :user, null: false, foreign_key: true
      t.string :mood
      t.text :note
      t.date :reflection_date

      t.timestamps
    end
  end
end
