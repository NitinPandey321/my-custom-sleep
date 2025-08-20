# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create test users for development
if Rails.env.development?
  # Admin user
  admin = User.find_or_create_by(email: 'admin@sleepjourney.com') do |user|
    user.first_name = 'Admin'
    user.last_name = 'User'
    user.password = 'password123'
    user.password_confirmation = 'password123'
    user.role = 'admin'
    user.onboarding_completed = true
  end

  # Create multiple coaches for round-robin testing
  coaches_data = [
    { email: 'sarah@sleepjourney.com', first_name: 'Sarah', last_name: 'Johnson' },
    { email: 'mike@sleepjourney.com', first_name: 'Mike', last_name: 'Rodriguez' },
    { email: 'emily@sleepjourney.com', first_name: 'Emily', last_name: 'Chen' },
    { email: 'david@sleepjourney.com', first_name: 'David', last_name: 'Thompson' }
  ]

  coaches_data.each do |coach_data|
    User.find_or_create_by(email: coach_data[:email]) do |user|
      user.first_name = coach_data[:first_name]
      user.last_name = coach_data[:last_name]
      user.password = 'password123'
      user.password_confirmation = 'password123'
      user.role = 'coach'
      user.onboarding_completed = true
    end
  end

  # Create a test client (without coach initially to test assignment)
  client = User.find_or_create_by(email: 'client@sleepjourney.com') do |user|
    user.first_name = 'John'
    user.last_name = 'Doe'
    user.password = 'password123'
    user.password_confirmation = 'password123'
    user.role = 'client'
    user.onboarding_completed = true
  end

  puts "Seeded #{User.count} users for development:"
  puts "- 1 Admin"
  puts "- #{User.coaches.count} Coaches"
  puts "- #{User.clients.count} Clients"
end
