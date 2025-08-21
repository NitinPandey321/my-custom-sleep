class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :user # sender

  validates :body, presence: true

  after_create_commit do
    broadcast_append_to conversation,
      target: "messages_#{conversation.id}",
      partial: "messages/message",
      locals: { message: self }
  end
end
