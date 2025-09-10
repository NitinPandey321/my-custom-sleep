class UpdateByToAuditLog < ActiveRecord::Migration[8.0]
  def change
    add_column :audit_logs, :updated_by, :integer
  end
end
