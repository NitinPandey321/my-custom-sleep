class DashboardsController < ApplicationController
  before_action :require_login

  def client
    @client = current_user
    @coach = @client.coach
    @conversation = Conversation.between(@client.id, @coach.id).first_or_create
    @messages = @conversation.messages.order(created_at: :asc)
    @new_message = @conversation.messages.build
  end

  def coach
    if params[:recipient_id].present?
      @recipient = User.find(params[:recipient_id])
      @conversation = Conversation.between(current_user.id, @recipient.id).first_or_create
      @messages = @conversation.messages.order(created_at: :asc)
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

    @total_clients = @coach.clients.count
    @active_clients = @coach.clients.count # You can add more specific logic for active clients
    @pending_approvals = 5 # Placeholder - you can implement this based on your business logic
  end

  def admin
    # Admin dashboard - placeholder
  end

  def show_new_plan
    @show_new_plan_card = true
    # Optionally, set @selected_client = Client.find(params[:client_id])
    render :coach # or whatever your dashboard view is
  end
end
