class DailyReflection < ApplicationRecord
  MOODS = {
    "happy" => "😊 Happy",
    "neutral" => "😐 Neutral",
    "tired" => "😴 Tired"
  }.freeze

  belongs_to :user
  validates :reflection_date, uniqueness: { scope: :user_id, message: "already submitted for today" }
  validates :mood, presence: true, inclusion: { in: MOODS.keys, message: "%{value} is not a valid mood" }
end
