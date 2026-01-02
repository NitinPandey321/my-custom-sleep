class ApplicationMailer < ActionMailer::Base
  default from: "contact@mycustomsleepjourney.com"
  layout "mailer"

  private

  def company_name
    "My Custom Sleep Journey"
  end
end
