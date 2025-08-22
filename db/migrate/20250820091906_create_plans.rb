class CreatePlans < ActiveRecord::Migration[8.0]
  def change
    create_table :plans do |t|
      t.references :user, null: false, foreign_key: true
      t.text :details, null: false
      t.integer :wellness_pillar, default: 0, null: false
       t.integer :status, default: 0, null: false
      t.datetime :duration
      t.integer :reminder_time
      t.timestamps
    end
  end
end
