# app/controllers/admin/dashboard_controller.rb
module Admin
  class DashboardController < ApplicationController
    def index
      @total_users = User.count
      @total_coaches = User.where(role: "coach").count
      @total_clients = User.where(role: "client").count
      @total_plans = Plan.count
      @pending_plans = Plan.where(status: "pending").count
    end
  end
end
