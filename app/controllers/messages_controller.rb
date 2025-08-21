class MessagesController < ApplicationController
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
end
