class SleepRecord < ApplicationRecord
  belongs_to :user
  validates :date, :score, presence: true
end
