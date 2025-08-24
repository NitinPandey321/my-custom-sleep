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
    session[:user_id] = nil
    flash[:notice] = "You have been logged out"
    redirect_to login_path
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
