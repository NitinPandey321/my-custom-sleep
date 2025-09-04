class ConversationsController < ApplicationController
  before_action :set_conversation, only: [ :escalate, :dismiss ]

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

  def escalate
    Turbo::StreamsChannel.broadcast_update_to(
      "user_#{@conversation.users.where(role: :client).first.id}",
      target: "escalation_popup",
      partial: "conversations/escalation_waiting"
    )

    User.coaches.where.not(id: @conversation.coach.id).each do |coach|
      Turbo::StreamsChannel.broadcast_append_to(
        "user_#{coach.id}",
        target: "coach_requests",
        partial: "conversations/coach_request",
        locals: { conversation: @conversation, client: @conversation.users.where(role: :client).first }
      )
    end
  end

  def dismiss
    Turbo::StreamsChannel.broadcast_update_to(
      "user_#{@conversation.users.where(role: :client).first.id}",
      target: "escalation_popup",
      html: "" # empties the frame
    )
  end

  def accept_request
    @conversation = Conversation.find(params[:id])
    client_id = @conversation.users.where(role: :client).first.id

    if @conversation.conversation_participants.none? { |p| p.user_id == current_user.id }
      @conversation.conversation_participants.create!(
        user: current_user,
        role: :temp_coach
      )
    end

    @conversation.messages.create!(user: current_user,
      body: "Coach #{current_user.full_name} has joined the conversation."
    )

    User.coaches.where.not(id: @conversation.coach.id).each do |coach|
      Turbo::StreamsChannel.broadcast_update_to(
        "user_#{coach.id}",
        target: "coach_request_#{@conversation.id}",
        html: "" # clears request card but keeps container alive
      )
    end

    Turbo::StreamsChannel.broadcast_update_to(
      "user_#{client_id}",
      target: "escalation_popup",
      partial: "conversations/new_coach_joined",
      locals: { coach: current_user }
    )
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "coach_redirect",
          partial: "shared/redirect",
          locals: { url: dashboards_coach_path(recipient_id: client_id) }
        )
      end
      format.html { redirect_to dashboards_coach_path(recipient_id: client_id) }
    end
  end

  def dismiss_request
    Turbo::StreamsChannel.broadcast_update_to(
      "user_#{current_user.id}",
      target: "coach_request_#{params[:id]}",
      html: "" # clears request card for this coach only
    )
  end

  private

  def authorize_conversation!
    unless [ @conversation.sender, @conversation.recipient ].include?(current_user)
      redirect_to root_path, alert: "Not authorized"
    end
  end

  def set_conversation
    @conversation = Conversation.find(params[:id])
  end
end
