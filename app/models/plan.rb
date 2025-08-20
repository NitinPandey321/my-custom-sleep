class Plan < ApplicationRecord
  belongs_to :user
  validates :wellness_pillar, presence: true
  validates :details, presence: true

  enum :wellness_pillar, {
  physical: 0,
  mental: 1,
  emotional: 2,
  financial: 3
}, prefix: true

end
