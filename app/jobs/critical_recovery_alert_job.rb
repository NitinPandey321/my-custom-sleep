class CriticalRecoveryAlertJob
  include Sidekiq::Job

  def perform
    User.clients.joins(:sleep_records).where("sleep_records.score <= ?", 30).find_each do |user|
      next unless user.full_phone.present?

      send_client_alert(user)
      send_coach_alert(user)
    end
  end

  private

  def send_client_alert(user)
    full_url = "#{ENV['BASE_URL']}/dashboards/client"

    message = "URGENT SAFETY ALERT: Dr. #{user.last_name}, your Oura data shows a critical recovery score below 30. " \
              "Your fatigue risk is high. Please prioritize rest immediately and notify your supervisor if on-shift. #{full_url}"

    TwilioClient.send_sms(to: user.full_phone, body: message)
    Rails.logger.info "Sent critical recovery alert to #{user.full_phone} (User ##{user.id})"
  end

  def send_coach_alert(user)
    full_url = "#{ENV['BASE_URL']}/dashboards/coach"
    coach = user.coach
    return unless coach&.full_phone.present?

    message = "URGENT: Client #{user.full_name} has entered a Red Zone (Oura Score 30). " \
              "High risk of exhaustion. Please reach out immediately to provide emergency shift support. #{full_url}"

    TwilioClient.send_sms(to: coach.full_phone, body: message)
    Rails.logger.info "Sent critical recovery alert to Coach #{coach.full_phone} for User ##{user.id}"
  end
end
