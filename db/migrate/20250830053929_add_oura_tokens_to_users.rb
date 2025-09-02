class AddOuraTokensToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :oura_access_token, :string
    add_column :users, :oura_refresh_token, :string
    add_column :users, :oura_expires_at, :datetime
  end
end
