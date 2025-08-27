class CreateAuditLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :audit_logs do |t|
      t.references :user, foreign_key: true
      t.string :role, null: false
      t.integer :action, null: false
      t.references :auditable, polymorphic: true
      t.text :details
      t.inet :ip_address
      t.string :user_agent

      t.timestamps
    end
  end
end
