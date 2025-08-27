class AddPlanStreakToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :plan_streak, :integer, default: 0, null: false
    add_column :users, :longest_plan_streak, :integer, default: 0, null: false
  end
end
