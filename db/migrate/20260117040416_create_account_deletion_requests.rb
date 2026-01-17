class CreateAccountDeletionRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :account_deletion_requests do |t|
      t.string :email

      t.timestamps
    end
  end
end
