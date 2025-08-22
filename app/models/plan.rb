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

  enum :status, {
    created: 0,
    pending: 1,
    approved: 2,
    needs_resubmission: 3
  }, prefix: true

  has_one_attached :proof
end
