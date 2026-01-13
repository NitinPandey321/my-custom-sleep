class AppInactivityAlertJob
  include Sidekiq::Job

  INACTIVITY_DAYS = 3

  def perform
    cutoff_time = INACTIVITY_DAYS.days.ago

    # Find users who haven't been active in 3 days
    User.clients.where("last_seen_at <= ?", cutoff_time).find_each do |user|
      next unless user.full_phone.present?

      send_inactivity_sms(user)
    end
  end

  private

  def send_inactivity_sms(user)
    dashboard_url = "#{ENV['BASE_URL']}/dashboards/client"

    message = "Hi #{user.last_name}, we know things get busy on-shift. " \
              "We’ve missed you in the app! Take a moment to check your plan and stay on track: #{dashboard_url}. " \
              "We’re here if you need us."

    # TwilioClient.send_sms(to: user.full_phone, body: message)
    UserMailer.inactivity_reminder(user).deliver_later

    Rails.logger.info "Sent inactivity alert to #{user.full_phone} (User ##{user.id})"
  end
end
