class Conversation < ApplicationRecord
  belongs_to :sender, class_name: "User"
  belongs_to :recipient, class_name: "User"

  has_many :messages, dependent: :destroy

  validates :sender_id, uniqueness: { scope: :recipient_id }
  validate :coach_client_relationship

  scope :between, ->(sender_id, recipient_id) do
    where(sender_id: sender_id, recipient_id: recipient_id)
      .or(where(sender_id: recipient_id, recipient_id: sender_id))
  end

  def other_participant(current_user)
    sender == current_user ? recipient : sender
  end

  private

  def coach_client_relationship
    # return if sender.coach_id == recipient.id || recipient.coach_id == sender.id
    # errors.add(:base, "Conversations can only exist between a coach and their client")
  end
end
