class UserActivityLog < ApplicationRecord
  belongs_to :user

  validates :date, presence: true
  validates :total_seconds, numericality: { greater_than_or_equal_to: 0 }

  def self.log_activity(user, seconds)
    record = user.user_activity_logs.find_or_initialize_by(date: Date.current)
    record.total_seconds ||= 0
    record.total_seconds += seconds.to_i
    record.save!
  end
end
