require "twilio-ruby"

class TwilioClient
  def self.client
    @client ||= Twilio::REST::Client.new(
      ENV["TWILIO_ACCOUNT_SID"],
      ENV["TWILIO_AUTH_TOKEN"]
    )
  end

  # Send SMS
  def self.send_sms(to:, body:)
    return nil unless to.include?("+1") # Only US/Canada numbers supported

    client.messages.create(
      from: ENV["TWILIO_PHONE_NUMBER"],
      to: to,
      body: body,
      status_callback: ENV["TWILIO_STATUS_CALLBACK_URL"] # webhook for instant updates
    )
  rescue Twilio::REST::RestError => e
    Rails.logger.error("Twilio SMS failed: #{e.message}")
    nil
  end

  # Fetch status of a message by SID
  def self.message_status(message_sid)
    message = client.messages(message_sid).fetch
    {
      sid: message.sid,
      status: message.status,            # queued, sent, delivered, failed, etc.
      error_code: message.error_code,    # if any
      error_message: message.error_message
    }
  rescue Twilio::REST::RestError => e
    Rails.logger.error("Failed to fetch SMS status: #{e.message}")
    nil
  end
end
