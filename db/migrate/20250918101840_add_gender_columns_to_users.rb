class AddGenderColumnsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :gender, :string
    add_column :users, :preferred_coach_gender, :string
  end
end
