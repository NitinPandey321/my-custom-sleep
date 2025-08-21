class ConversationsController < ApplicationController
  def index
    @recipient = User.find(params[:recipient_id])
    @sender = User.find(params[:sender_id])
    @messages = Conversation.between(@sender.id, @recipient.id).first_or_create.messages

    render partial: "active_chats_card",
         locals: { messages: @messages, recipient: @recipient }

  end

  def show
    @conversation = Conversation.find(params[:id])
    authorize_conversation!
    @messages = @conversation.messages.includes(:user)
    @message = Message.new
  end

  def create
    @conversation = Conversation.between(params[:sender_id], params[:recipient_id]).first ||
                    Conversation.create!(sender_id: params[:sender_id], recipient_id: params[:recipient_id])
    redirect_to @conversation
  end

  private

  def authorize_conversation!
    unless [@conversation.sender, @conversation.recipient].include?(current_user)
      redirect_to root_path, alert: "Not authorized"
    end
  end
end
