class PlanProofUploadReminderJob
  include Sidekiq::Job

  REMINDER_WINDOW_START = 55.minutes
  REMINDER_WINDOW_END   = 65.minutes

  def perform
    Plan.where(status: [ :created, :pending ]).find_each do |plan|
      next unless plan.duration
      cache_key = "plan:#{plan.id}:one_hour_proof_reminder_sent"
      next if Rails.cache.exist?(cache_key)

      remaining_seconds = plan.duration - Time.current
      next unless remaining_seconds.positive?

      if one_hour_left?(remaining_seconds)
        send_email(plan)
        Rails.cache.write(cache_key, true, expires_in: 1.hour)
      end
    end
  end

  private

  def one_hour_left?(remaining_seconds)
    remaining_seconds.between?(
      REMINDER_WINDOW_START,
      REMINDER_WINDOW_END
    )
  end

  def send_email(plan)
    PlanMailer
      .proof_upload_reminder(plan.user, plan)
      .deliver_later
  end
end
