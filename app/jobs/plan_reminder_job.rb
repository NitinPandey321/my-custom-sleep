class PlanReminderJob
  include Sidekiq::Job

  def perform
    Plan.where(status: [ :created, :pending ]).find_each do |plan|
      next unless plan.duration && plan.reminder_time

      remaining_hours = ((plan.duration - Time.current) / 1.hour).round
      if remaining_hours == plan.reminder_time
        send_reminder(plan)
      end
    end
  end

  private

  def send_reminder(plan)
    user = plan.user
    return unless user.phone_number.present?

    full_url = "http://localhost:3000/dashboards/client"

    message = "Hi #{user.full_name}, your plan for #{plan.wellness_pillar} is due in #{plan.reminder_time} hours. Complete it here: #{full_url}"

    TwilioClient.send_sms(to: user.full_phone, body: message)
    Rails.logger.info "Sent reminder to #{user.full_phone} for Plan #{plan.id}"
  end
end
