class DashboardsController < ApplicationController
  before_action :require_login

  def client
    redirect_to root_path and return unless current_user.role == "client"
    @client = current_user
    @coach = @client.coach
    @plans_by_pillar = current_user.plans.group_by(&:wellness_pillar)
    current_user.mark_messages_as_read(@coach)
    @conversation = Conversation.between(@client.id, @coach.id)
    @messages = @conversation.messages.order(created_at: :asc)
    @new_message = @conversation.messages.build
  end

  def coach
    redirect_to root_path and return unless current_user.role == "coach"
    @recipient = User.find_by(id: params[:recipient_id], role: "client")
    if @recipient.present?
      @conversation = Conversation.between(current_user.id, @recipient&.id)
      if @conversation.nil?
        redirect_to dashboards_coach_path, alert: "No conversation found with the selected client."
      else
        @messages = @conversation.messages.order(created_at: :asc)
        current_user.mark_messages_as_read(@recipient)
        @new_message = @conversation.messages.build
      end
    end

    if params[:client_id].present?
      @client = User.find(params[:client_id])
    end

    if params[:plan_id].present?
      @plan = Plan.find(params[:plan_id])
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

  def logs
    if current_user.role != "coach"
      redirect_to root_path, alert: "Access denied."
      return
    end
    user_ids = [ current_user.id ]
    if params[:client_id].present?
      user_ids = [ params[:client_id] ]
    else
      user_ids += current_user.clients.pluck(:id)
    end
    @audit_logs = AuditLog.where(user_id: user_ids).order(created_at: :desc)
  end
end
