# app/models/audit_log.rb
class AuditLog < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :auditable, polymorphic: true, optional: true

  enum :action, {
    plan_created: 0,
    plan_submitted: 1,
    plan_submitted_on_time: 2,
    plan_submitted_late: 3,
    plan_approved: 4,
    plan_resubmission_requested: 5,
    conversation_started: 6,
    logged_in: 7,
    logged_out: 8,
    profile_updated: 9,
    account_deactivated: 10,
    account_reactivated: 11
  }, prefix: true

  validates :role, presence: true
  validates :action, presence: true
end
