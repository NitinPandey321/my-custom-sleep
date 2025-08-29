class DashboardsController < ApplicationController
  before_action :require_login

  def client
    @client = current_user
    @coach = @client.coach
    current_user.mark_messages_as_read(@coach)
    @conversation = Conversation.between(@client.id, @coach.id).first_or_create
    if @conversation.id.nil?
      Conversation.create(sender: @client, recipient: @coach)
      @conversation = Conversation.between(@client.id, @coach.id).first_or_create
    end
    @messages = @conversation.messages.order(created_at: :asc)
    @new_message = @conversation.messages.build
  end

  def coach
    if params[:recipient_id].present?
      @recipient = User.find(params[:recipient_id])
      @conversation = Conversation.between(current_user.id, @recipient.id).first_or_create
      if @conversation.id.nil?
        Conversation.create(sender: @recipient, recipient: current_user)
        @conversation = Conversation.between(@recipient.id, current_user.id).first_or_create
      end
      @messages = @conversation.messages.order(created_at: :asc)
      current_user.mark_messages_as_read(@recipient)
      @new_message = @conversation.messages.build
    end

    if params[:client_id].present?
      @client = User.find(params[:client_id])
    end
    @coach = current_user
    @clients = @coach.clients
    # Search
    if params[:search].present?
      @clients = @clients.where("first_name ILIKE ? OR last_name ILIKE ?", "%#{params[:search]}%", "%#{params[:search]}%")
    end

    # Filter by status
    if params[:status].present? && params[:status] != "All Status"
      @clients = @clients.where(status: User.statuses[params[:status]])
    end

    @clients = @clients
              .left_joins(:messages)
              .select("users.*, MAX(messages.created_at) AS last_message_at")
              .group("users.id")
              .order("last_message_at DESC NULLS LAST")

    @total_clients = @coach.clients.count
    @active_clients = @coach.clients.count # You can add more specific logic for active clients
    @pending_approvals = 5 # Placeholder - you can implement this based on your business logic
  end

  def admin
    # Admin dashboard - placeholder
    @total_users = User.count
    @total_coaches = User.where(role: "coach").count
    @total_clients = User.where(role: "client").count
    @total_plans = Plan.count
    @pending_plans = Plan.where(status: "pending").count
  end

  def show_new_plan
    @show_new_plan_card = true
    # Optionally, set @selected_client = Client.find(params[:client_id])
    render :coach # or whatever your dashboard view is
  end
end
