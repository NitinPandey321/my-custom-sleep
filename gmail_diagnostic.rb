#!/usr/bin/env ruby
# Gmail Troubleshooting Diagnostic
# Run with: rails runner gmail_diagnostic.rb

puts "🔍 Gmail App Password Diagnostic"
puts "=" * 50

# Check environment variables
puts "1. Environment Variables:"
puts "   Username: #{ENV['GMAIL_USERNAME']}"
puts "   Password: #{ENV['GMAIL_APP_PASSWORD'] ? '[SET]' : '[NOT SET]'}"
puts "   Password Length: #{ENV['GMAIL_APP_PASSWORD']&.length || 0} chars"
puts "   Password Format: #{ENV['GMAIL_APP_PASSWORD']}"
puts

# Check for common issues
password = ENV['GMAIL_APP_PASSWORD']
if password
  puts "2. Password Analysis:"
  puts "   Contains spaces: #{password.include?(' ') ? 'YES ❌' : 'NO ✅'}"
  puts "   Contains hyphens: #{password.include?('-') ? 'YES ❌' : 'NO ✅'}"
  puts "   All lowercase: #{password.downcase == password ? 'YES ✅' : 'NO ⚠'}"
  puts "   Length is 16: #{password.length == 16 ? 'YES ✅' : "NO ❌ (#{password.length})"}"
  puts

  # Show character breakdown
  puts "3. Character Breakdown:"
  password.chars.each_with_index do |char, i|
    puts "   Position #{i+1}: '#{char}' (#{char.ord})"
  end
  puts
end

puts "4. Common Gmail App Password Issues:"
puts "   • App Password contains spaces (should be removed)"
puts "   • 2-Factor Authentication not fully enabled"
puts "   • App Password generated for wrong application type"
puts "   • Account has security restrictions"
puts "   • Less Secure App Access is disabled (shouldn't matter for App Passwords)"
puts

puts "5. Required Gmail Settings:"
puts "   ✓ 2-Factor Authentication: MUST be enabled"
puts "   ✓ App Password: Generate for 'Mail' or 'Other'"
puts "   ✓ Account type: Personal Gmail (not Google Workspace)"
puts

puts "6. Testing Different Formats:"
if password
  # Test without spaces
  no_spaces = password.gsub(/\s+/, '')
  puts "   Original: '#{password}'"
  puts "   No spaces: '#{no_spaces}'"
  puts "   Length without spaces: #{no_spaces.length}"
end
