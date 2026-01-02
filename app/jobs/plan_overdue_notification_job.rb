class PlanOverdueNotificationJob
  include Sidekiq::Job

  FOUR_HOUR_WINDOW   = 4.hours
  SLA_BREACH_WINDOW  = 24.hours

  def perform
    Plan.where(status: :pending).find_each do |plan|
      now = Time.current
      elapsed_time = now - plan.created_at

      coach_cache_key = "plan:#{plan.id}:coach_overdue_sent"
      admin_cache_key = "plan:#{plan.id}:admin_sla_breach_sent"

      if elapsed_time >= FOUR_HOUR_WINDOW && !Rails.cache.exist?(coach_cache_key)
        PlanMailer.coach_submission_overdue(plan).deliver_later

        Rails.cache.write(coach_cache_key, true, expires_in: 6.hours)
        Rails.logger.info "Coach overdue email sent for Plan ##{plan.id}"
      end

      if elapsed_time >= SLA_BREACH_WINDOW && !Rails.cache.exist?(admin_cache_key)
        PlanMailer.admin_sla_breach(plan).deliver_later

        Rails.cache.write(admin_cache_key, true, expires_in: 30.hours)
        Rails.logger.info "Admin SLA breach email sent for Plan ##{plan.id}"
      end
    end
  end
end
