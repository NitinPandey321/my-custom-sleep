class MessagesController < ApplicationController
  before_action :require_login
  before_action :set_conversation, only: [ :create ]

 def create
    # If no conversation is found, create one
    unless @conversation
      @conversation = Conversation.create!(
        sender: current_user,
        recipient_id: params[:recipient_id] # pass recipient_id in form or params
      )
    end

    @recipient = @conversation.other_participant(current_user)

    @message = @conversation.messages.new(message_params.merge(user: current_user))
    if @message.save
      ActionCable.server.broadcast(
        "conversation_#{@conversation.id}",
        {
          type: "new_message",
          message: message_json(@message)
        }
      )

      @conversation.users.each do |user|
        ActionCable.server.broadcast(
          "user_#{user.id}_conversations",
          {
            type: "conversation_updated",
            conversation: conversation_json(@conversation, user)
          }
        )
      end
      @new_message = Message.new
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to conversation_path(@conversation) }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_conversation
    @conversation = Conversation.find(params[:conversation_id])
  end

  def message_params
    params.require(:message).permit(:body)
  end

  def conversation_json(conversation, viewer)
    other = conversation.users.where.not(id: viewer.id).first
    last_message = conversation.messages.last

    {
      id: conversation.id,
      participant: {
        id: other&.id,
        name: other&.full_name,
        role: other&.role,
        online: other&.online?,
        profile_picture_url: other&.profile_picture.attached? ? url_for(other.profile_picture) : nil,
      },
      last_message: last_message&.body,
      last_message_at: last_message&.created_at,
      unread_count: viewer.unread_messages_count(other)
    }
  end

  def message_json(message)
    {
      id: message.id,
      body: message.body,
      user_id: message.user_id,
      user_name: message.user.full_name,
      created_at: message.created_at,
      mine: message.user_id == current_user.id
    }
  end
end
