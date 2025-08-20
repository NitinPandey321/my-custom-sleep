#!/usr/bin/env ruby
# Quick email test script
# Run with: rails runner test_email.rb

puts "🧪 Testing Email Configuration..."
puts "=" * 50

# Check environment variables
puts "Gmail Username: #{ENV['GMAIL_USERNAME'] || 'NOT SET'}"
puts "Gmail Password: #{ENV['GMAIL_APP_PASSWORD'] ? '[CONFIGURED]' : 'NOT SET'}"
puts

# Create a test user
test_user = User.new(
  first_name: "Test",
  last_name: "User", 
  email: "iamtheworst369@gmail.com",
  role: "client"
)

puts "📧 Attempting to send test welcome email..."

if EmailService.send_welcome_email(test_user)
  puts "✅ Email sent successfully!"
  puts "📬 Check your inbox: iamtheworst369@gmail.com"
else
  puts "❌ Email failed to send"
  puts "📋 Check the logs for details"
end

puts
puts "💡 If email didn't arrive:"
puts "   1. Check spam folder"
puts "   2. Verify Gmail App Password in .env file"
puts "   3. Check Rails logs for errors"
