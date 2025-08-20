# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  def welcome_email
    # Create a sample user for preview
    user = User.new(
      first_name: "John",
      last_name: "Doe", 
      email: "john.doe@example.com",
      role: "client"
    )
    UserMailer.welcome_email(user)
  end
end
