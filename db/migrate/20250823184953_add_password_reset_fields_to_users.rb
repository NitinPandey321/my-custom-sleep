class AddPasswordResetFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :reset_password_otp_digest, :string
    add_column :users, :reset_password_sent_at, :datetime
    add_column :users, :reset_password_attempts, :integer, default: 0
  end
end
