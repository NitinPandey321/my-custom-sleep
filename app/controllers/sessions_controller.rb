class SessionsController < ApplicationController
  before_action :redirect_if_logged_in, only: [:new, :create]

  def new
    # Login form
  end

  def create
    user = User.find_by(email: params[:email]&.downcase)
    
    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      flash[:notice] = "Welcome back, #{user.first_name}!"
      redirect_to dashboard_path_for(user.role)
    else
      flash.now[:alert] = "Invalid email or password"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
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

  def dashboard_path_for(role)
    case role
    when 'client'
      '/client/dashboard'
    when 'coach'
      '/coach/dashboard'
    when 'admin'
      '/admin/dashboard'
    else
      login_path
    end
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  rescue ActiveRecord::RecordNotFound
    session[:user_id] = nil
    nil
  end
end
