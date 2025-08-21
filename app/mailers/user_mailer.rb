class UserMailer < ApplicationMailer
  default from: "noreply@mycustomsleepjourney.com"

  def welcome_email(user)
    @user = user
    @company_name = "My Custom Sleep Journey"

    mail(
      to: @user.email,
      subject: "Welcome to My Custom Sleep Journey"
    )
  end
end
