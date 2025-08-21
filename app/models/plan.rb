class Plan < ApplicationRecord
  belongs_to :user
  validates :wellness_pillar, presence: true
  validates :details, presence: true

  enum :wellness_pillar, {
  nutrition: 0,
  supplements: 1,
  hypnosis: 2,
  caffine: 3,
  excercise: 4
}, prefix: true
end
