class ConversationChannel < ApplicationCable::Channel
  def subscribed
    conversation = Conversation.find_by(id: params[:conversation_id])

    if conversation && conversation.users.include?(current_user)
      stream_from "conversation_#{conversation.id}"
    else
      reject
    end
  end
end
