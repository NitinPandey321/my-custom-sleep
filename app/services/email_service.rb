class EmailService
  EMAILS = {
    welcome: {
      subject: "Welcome to My Custom Sleep Journey",
      mailer: ->(user, _) { UserMailer.welcome_email(user) }
    },
    verification: {
      subject: "Please verify your new email address",
      mailer: ->(user, new_email) { UserMailer.verification_email(user, new_email) }
    }
  }.freeze

  class << self
    def send_welcome_email(user)
      return false unless user&.role == "client"

      send_email(user: user, type: :welcome)
    end

    def send_verification_email(user, new_email)
      send_email(user: user, type: :verification, extra_arg: new_email)
    end

    private

    def send_email(user:, type:, extra_arg: nil)
      config = EMAILS.fetch(type)

      config[:mailer].call(user, extra_arg).deliver_now
      log_email(user, type, config[:subject], "sent")

      true
    rescue => e
      log_email(user, type, config[:subject], "failed", e.message)
      Rails.logger.error "✗ Failed to send #{type} email: #{e.message}"
      false
    end

    def log_email(user, type, subject, status, error = nil)
      return unless user&.persisted?

      EmailLog.create!(
        user: user,
        email_type: type,
        subject: subject,
        status: status,
        sent_at: Time.current,
        error_message: error
      )
    end
  end
end
