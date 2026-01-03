class Conversation < ApplicationRecord
  has_many :conversation_participants, dependent: :destroy
  has_many :users, through: :conversation_participants

  has_many :messages, dependent: :destroy

  def other_participant(current_user)
    users.where.not(id: current_user.id).first
  end

  def create_participant(user)
    conversation_participants.create!(user: user, role: user.role)
  end

  def self.between(sender_id, recipient_id)
    joins(:conversation_participants)
      .where(conversation_participants: { user_id: [ sender_id, recipient_id ] })
      .group(:id).having("COUNT(DISTINCT conversation_participants.user_id) >= 2").first
  end

  def self.new_conversation(sender_id:, recipient_id:)
    existing = between(sender_id, recipient_id)
    return existing if existing

    Conversation.create!(conversation_participants: [
      ConversationParticipant.new(user_id: sender_id, role: User.user_role(sender_id)),
      ConversationParticipant.new(user_id: recipient_id, role: User.user_role(recipient_id))
    ])
  end

  def coach
    conversation_participants.find_by(role: :coach).user
  end

  def client
    conversation_participants.find_by(role: :client).user
  end

  def temp_coach
    conversation_participants.find_by(role: :temp_coach).user
  end
end
