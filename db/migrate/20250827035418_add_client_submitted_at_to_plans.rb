class AddClientSubmittedAtToPlans < ActiveRecord::Migration[8.0]
  def change
    add_column :plans, :client_submitted_at, :datetime
  end
end
