class UserMailer < ApplicationMailer
  default from: "contact@mycustomsleepjourney.com"

  def welcome_email(user)
    @user = user
    @company_name = "My Custom Sleep Journey"

    mail(
      to: @user.email,
      subject: "Welcome to My Custom Sleep Journey"
    )
  end

  def send_reset_password_otp(user, otp)
    @user = user
    @otp = otp
    @company_name = "My Custom Sleep Journey"

    mail(
      to: @user.email,
      subject: "Password Reset OTP - My Custom Sleep Journey"
    )
  end

  def verification_email(user, new_email)
    @user = user
    @new_email = new_email
    @company_name = "My Custom Sleep Journey"

    mail(
      to: @new_email,
      subject: "Verify Your New Email Address - My Custom Sleep Journey"
    )
  end

  def inactivity_reminder(user)
    @user = user
    @dashboard_url = root_url
    mail(to: @user.email, subject: "We Missed You in the App")
  end
end
