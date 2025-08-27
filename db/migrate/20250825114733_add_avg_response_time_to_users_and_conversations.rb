class AddAvgResponseTimeToUsersAndConversations < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :avg_response_time, :integer, default: 0, null: false
    add_column :conversations, :avg_response_time, :integer, default: 0, null: false
  end
end
