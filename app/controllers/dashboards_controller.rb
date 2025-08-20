class DashboardsController < ApplicationController
  before_action :require_login

  def client
    @client = current_user
    @coach = @client.coach
  end

  def coach
    @coach = current_user
    @total_clients = @coach.clients.count
    @active_clients = @coach.clients.count # You can add more specific logic for active clients
    @pending_approvals = 5 # Placeholder - you can implement this based on your business logic
  end

  def admin
    # Admin dashboard - placeholder
  end
end
