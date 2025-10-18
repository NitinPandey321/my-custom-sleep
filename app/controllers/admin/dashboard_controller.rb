# app/controllers/admin/dashboard_controller.rb
module Admin
  class DashboardController < ApplicationController
    def index
      @total_users = User.count
      @total_coaches = User.where(role: "coach").count
      @total_clients = User.where(role: "client").count
      @total_plans = Plan.count
      @pending_plans = Plan.where(status: "pending").count
      @top_coaches = User.coaches
                       .joins(:user_activity_logs)
                       .select("users.*, SUM(user_activity_logs.total_seconds) AS total_seconds")
                       .group("users.id")
                       .order("total_seconds DESC")
                       .limit(5)
    end
  end
end
