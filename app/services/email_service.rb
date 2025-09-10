class EmailService
  def self.send_welcome_email(user)
    return unless user.role == "client"

    begin
      # Check if SMTP is properly configured
      if smtp_configured?
        UserMailer.welcome_email(user).deliver_now
        Rails.logger.info "✓ Welcome email sent successfully to #{user.email} via SMTP"
      else
        # Fallback to letter_opener for development
        Rails.logger.warn "⚠ SMTP not configured, using letter_opener fallback"
        configure_letter_opener_fallback
        UserMailer.welcome_email(user).deliver_now
        Rails.logger.info "✓ Welcome email opened in browser for #{user.email}"
      end

      # Log successful email only if user is persisted (has an ID)
      if user.persisted?
        EmailLog.create!(
          user: user,
          email_type: "welcome",
          subject: "Welcome to My Custom Sleep Journey",
          status: "sent",
          sent_at: Time.current
        )
      end

      true
    rescue => e
      # Log failed email only if user is persisted (has an ID)
      if user.persisted?
        EmailLog.create!(
          user: user,
          email_type: "welcome",
          subject: "Welcome to My Custom Sleep Journey",
          status: "failed",
          sent_at: Time.current,
          error_message: e.message
        )
      end

      Rails.logger.error "✗ Failed to send welcome email to #{user.email}: #{e.message}"
      false
    end
  end

  def self.send_verification_email(user, new_email)
    begin
      if smtp_configured?
        UserMailer.verification_email(user, new_email).deliver_now
        Rails.logger.info "✓ Verification email sent successfully to #{new_email} via SMTP"
      else
        Rails.logger.warn "⚠ SMTP not configured, using letter_opener fallback"
        configure_letter_opener_fallback
        UserMailer.verification_email(user, new_email).deliver_now
        Rails.logger.info "✓ Verification email opened in browser for #{new_email}"
      end

      true
    rescue => e
      Rails.logger.error "✗ Failed to send verification email to #{new_email}: #{e.message}"
      false
    end
  end

  private

  def self.smtp_configured?
    ENV["GMAIL_USERNAME"].present? &&
    ENV["GMAIL_APP_PASSWORD"].present? &&
    ENV["GMAIL_APP_PASSWORD"] != "temp_password_for_testing"
  end

  def self.configure_letter_opener_fallback
    ActionMailer::Base.delivery_method = :letter_opener
  end
end
