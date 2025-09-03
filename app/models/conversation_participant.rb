class ConversationParticipant < ApplicationRecord
  belongs_to :conversation
  belongs_to :user
  enum :role, { client: 0, coach: 1, temp_coach: 2 }, prefix: true
end
