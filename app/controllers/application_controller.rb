class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  rescue ActiveRecord::RecordNotFound
    session[:user_id] = nil
    nil
  end

  helper_method :current_user

  def logged_in?
    !!current_user
  end

  helper_method :logged_in?

  def user_signed_in?
    logged_in?
  end

  helper_method :user_signed_in?

  def require_login
    unless logged_in?
      flash[:alert] = "You must be logged in to access this page"
      redirect_to login_path
    else
      current_user.update_column(:last_seen_at, Time.current)
    end
  end

  def require_admin
    unless current_user&.admin?
      redirect_to root_path, alert: "Access denied"
    end
  end

  def dashboard_path_for(role)
    case role
    when "client"
      dashboards_client_path
    when "coach"
      dashboards_coach_path
    when "admin"
      admin_dashboard_index_path
    else
      login_path
    end
  end
end
