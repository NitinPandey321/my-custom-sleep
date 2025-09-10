class AddEmailVerificationTokenToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :unverified_email, :string
    add_column :users, :email_verification_token, :string
  end
end
