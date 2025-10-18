class CreateUserActivityLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :user_activity_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.date :date
      t.integer :total_seconds

      t.timestamps
    end

    add_index :user_activity_logs, [:user_id, :date], unique: true
  end
end
