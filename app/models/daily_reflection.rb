class DailyReflection < ApplicationRecord
  belongs_to :user
  validates :reflection_date, uniqueness: { scope: :user_id, message: "already submitted for today" }
  validates :mood, presence: true
end
