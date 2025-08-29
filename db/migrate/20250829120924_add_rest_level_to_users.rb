class AddRestLevelToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :rest_level, :integer, default: 0, null: false
    add_column :users, :on_time_weeks, :integer, default: 0, null: false
    add_column :users, :missed_weeks, :integer, default: 0, null: false
  end
end
