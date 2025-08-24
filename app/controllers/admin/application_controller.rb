# app/controllers/admin/application_controller.rb
module Admin
  class ApplicationController < ActionController::Base
    layout "admin"
    before_action :require_admin

    private

    def require_admin
      unless current_user&.admin?
        redirect_to root_path, alert: "Access denied"
      end
    end

    def current_user
      # Your existing current_user method
      @current_user ||= User.find_by(id: session[:user_id])
    end
  end
end
