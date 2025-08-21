#!/usr/bin/env ruby
# Test alternative Gmail SMTP settings
# Run with: rails runner alternative_smtp_test.rb

require 'net/smtp'

puts "🔧 Testing Alternative Gmail SMTP Settings"
puts "=" * 50

username = ENV['GMAIL_USERNAME']
password = ENV['GMAIL_APP_PASSWORD']

puts "Testing with SSL (Port 465) instead of STARTTLS (Port 587)..."
puts

begin
  puts "📡 Connecting to smtp.gmail.com:465 with SSL..."

  smtp = Net::SMTP.new('smtp.gmail.com', 465)
  smtp.enable_ssl  # Use SSL instead of STARTTLS

  smtp.start('gmail.com', username, password, :plain) do |smtp_session|
    puts "✅ SSL SMTP authentication successful!"
    puts "🎉 Gmail connection established with alternative settings!"
  end

rescue => e
  puts "❌ SSL SMTP also failed: #{e.message}"
  puts
  puts "🔍 This confirms the issue is with your Google Account settings, not SMTP configuration."
  puts
  puts "📋 Please check:"
  puts "   1. Is 2-Factor Authentication fully enabled? (not just 'getting started')"
  puts "   2. Did you generate the App Password for 'Mail' or 'Other'?"
  puts "   3. Is this a personal Gmail account (not Google Workspace)?"
  puts "   4. Was the App Password generated in the last 24 hours?"
end
