# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create test users for development
if Rails.env.development?
  # Admin user
  admin = User.find_or_create_by(email: 'admin@example.com') do |user|
    user.first_name = 'Admin'
    user.last_name = 'User'
    user.password = 'password123'
    user.password_confirmation = 'password123'
    user.role = 'admin'
    user.onboarding_completed = true
  end

  # Coach user
  coach = User.find_or_create_by(email: 'sarah@example.com') do |user|
    user.first_name = 'Sarah'
    user.last_name = 'Wilson'
    user.password = 'password123'
    user.password_confirmation = 'password123'
    user.role = 'coach'
    user.onboarding_completed = true
  end

  # Client user
  client = User.find_or_create_by(email: 'john@example.com') do |user|
    user.first_name = 'John'
    user.last_name = 'Doe'
    user.password = 'password123'
    user.password_confirmation = 'password123'
    user.role = 'client'
    user.onboarding_completed = true
  end

  puts "Seeded #{User.count} users for development"
end

# Create test users for development
if Rails.env.development?
  admin = User.find_or_create_by!(email: 'admin@sleepjourney.com') do |user|
    user.first_name = 'Admin'
    user.last_name = 'User'
    user.password = 'password123'
    user.role = 'admin'
    user.onboarding_completed = true
  end

  client = User.find_or_create_by!(email: 'client@sleepjourney.com') do |user|
    user.first_name = 'John'
    user.last_name = 'Doe'
    user.password = 'password123'
    user.role = 'client'
    user.onboarding_completed = true
  end

  coach = User.find_or_create_by!(email: 'coach@sleepjourney.com') do |user|
    user.first_name = 'Sarah'
    user.last_name = 'Wilson'
    user.password = 'password123'
    user.role = 'coach'
    user.onboarding_completed = true
  end

  puts "Seeded test users: admin, client, and coach"
end
