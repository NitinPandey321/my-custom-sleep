#!/usr/bin/env ruby
# Simple SMTP test without database dependencies
# Run with: rails runner smtp_test.rb

require 'net/smtp'

puts "🔐 Testing SMTP Credentials..."
puts "=" * 40

username = ENV['GMAIL_USERNAME']
password = ENV['GMAIL_APP_PASSWORD']

puts "Username: #{username}"
puts "Password: #{password ? password.gsub(/./, '*') : 'NOT SET'}"
puts "Password length: #{password&.length || 0} characters"
puts

begin
  puts "📡 Attempting to connect to Gmail SMTP..."
  
  smtp = Net::SMTP.new('smtp.gmail.com', 587)
  smtp.enable_starttls
  smtp.start('gmail.com', username, password, :plain) do |smtp_session|
    puts "✅ SMTP authentication successful!"
    puts "📧 Connection to Gmail established."
  end
  
rescue => e
  puts "❌ SMTP authentication failed:"
  puts "   Error: #{e.message}"
  puts
  puts "💡 Possible solutions:"
  puts "   1. Verify your Gmail App Password is correct"
  puts "   2. Make sure 2-Factor Authentication is enabled"
  puts "   3. Check if the App Password has spaces (remove them)"
  puts "   4. Try generating a new App Password"
end
