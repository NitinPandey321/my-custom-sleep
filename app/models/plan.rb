class Plan < ApplicationRecord
  belongs_to :user
  validates :wellness_pillar, presence: true
  validates :details, presence: true
  validate :proof_required_for_specific_pillars, on: :update

  enum :wellness_pillar, {
  nutrition: 0,
  supplements: 1,
  hypnosis: 2,
  caffeine: 3,
  exercise: 4
}, prefix: true

  enum :status, {
    created: 0,
    pending: 1,
    approved: 2,
    needs_resubmission: 3
  }, prefix: true

  has_many_attached :proofs

  after_create :log_creation
  after_update :log_status_change

  private

  # When coach creates plan
  def log_creation
    AuditLog.create!(
      user: user,
      role: "coach",
      action: :plan_created,
      auditable: self,
      details: "Plan created for #{user.email} in #{wellness_pillar}",
      updated_by: user.coach_id
    )
  end

  def proof_required_for_specific_pillars
    if %w[exercise nutrition].include?(wellness_pillar) && !proofs.attached?
      errors.add(:proof, "is required for this type of plan")
    end
  end

  # When plan status changes
  def log_status_change
    return unless saved_change_to_status?

    case status
    when "pending"
      if duration && Time.current <= duration
        update_column(:client_submitted_at, Time.current)
        AuditLog.create!(
          user: user,
          role: "client",
          action: :plan_submitted_on_time,
          auditable: self,
          details: "Client submitted plan on time",
          updated_by: user.id
        )
      else
        AuditLog.create!(
          user: user,
          role: "client",
          action: :plan_submitted_late,
          auditable: self,
          details: "Client submitted plan late (due #{duration})",
          updated_by: user.id
        )
      end

    when "approved"
      AuditLog.create!(
        user: user,
        role: "coach",
        action: :plan_approved,
        auditable: self,
        details: "Coach approved client’s plan",
        updated_by: user.coach_id
      )

      if client_submitted_at.present? && duration && client_submitted_at <= duration
        user.plan_streak += 1
        user.longest_plan_streak = [ user.longest_plan_streak, user.plan_streak ].max
        user.save!
      else
        user.update!(plan_streak: 0)
      end
    when "needs_resubmission"
      AuditLog.create!(
        user: user,
        role: "coach",
        action: :plan_resubmission_requested,
        auditable: self,
        details: "Coach requested resubmission (reason: #{resubmission_reason})",
        updated_by: user.coach_id
      )
    end
  end
end
