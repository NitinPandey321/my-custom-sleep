class CreateEmailLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :email_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.string :email_type
      t.string :subject
      t.string :status
      t.datetime :sent_at
      t.text :error_message

      t.timestamps
    end
  end
end
