class AddResubmissionReasonToPlans < ActiveRecord::Migration[8.0]
  def change
    add_column :plans, :resubmission_reason, :text
  end
end
