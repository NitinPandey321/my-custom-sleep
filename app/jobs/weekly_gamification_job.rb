class WeeklyGamificationJob
  include Sidekiq::Worker

  def perform
    User.where(role: "client").find_each do |user|
      WeeklyGamificationService.new(user).check_week
    end
  end
end
