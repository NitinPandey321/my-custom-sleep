class SessionsController < ApplicationController
  before_action :redirect_if_logged_in, only: [ :new, :create ]

  def new
    # Login form
  end

  def create
    user = User.find_by(email: params[:email]&.downcase)

    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      flash[:notice] = "Welcome back, #{user.first_name}!"
      AuditLog.create!(
        user: user,
        role: user.role,
        action: :logged_in,
        auditable: user,
        details: "User logged in at #{Time.current}"
      )
      redirect_to dashboard_path_for(user.role)
    else
      flash.now[:alert] = "Invalid email or password"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    AuditLog.create!(
      user: current_user,
      role: current_user.role,
      action: :logged_out,
      auditable: current_user,
      details: "User logged out at #{Time.current}"
    )
    session[:user_id] = nil
    flash[:notice] = "You have been logged out"
    redirect_to login_path
  end

  private

  def redirect_if_logged_in
    if current_user
      redirect_to dashboard_path_for(current_user.role)
    end
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  rescue ActiveRecord::RecordNotFound
    session[:user_id] = nil
    nil
  end
end
