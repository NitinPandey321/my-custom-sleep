class ChatEscalationJob < ApplicationJob
  queue_as :default

  def perform(message_id)
    message = Message.find_by(id: message_id)
    return unless message&.user&.client?

    conversation = message.conversation
    last_message = conversation.messages.order(created_at: :desc).first

    # Only escalate if last message is still this client message
    if last_message.id == message.id
      Turbo::StreamsChannel.broadcast_update_to(
        "user_#{message.user.id}",
        target: "escalation_popup",
        partial: "conversations/escalation_popup",
        locals: { conversation: conversation }
      )
      
      ActionCable.server.broadcast(
        "user_#{message.user.id}_mobile",
        {
          type: "escalation",
          conversation_id: conversation.id,
          message_id: message.id,
          title: "New escalation",
          body: "Coach did not reply in time",
          created_at: message.created_at
        }
      )
    end
  end
end
