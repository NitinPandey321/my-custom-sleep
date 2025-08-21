class UsersController < ApplicationController
  before_action :redirect_if_logged_in

  def role_selection
    # Role selection page - no additional logic needed
  end

  def new_client
    @user = User.new
    @user.role = "client"
  end

  def new_coach
    @user = User.new
    @user.role = "coach"
  end

  def create_client
    @user = User.new(user_params)
    @user.role = "client"

    if @user.save
      # Assign a coach using round-robin
      assigned_coach = User.assign_coach_to_client(@user)

      # Send welcome email for new clients
      EmailService.send_welcome_email(@user)

      session[:user_id] = @user.id
      if assigned_coach
        flash[:notice] = "Welcome to Sleep Journey, #{@user.first_name}! You've been assigned to coach #{assigned_coach.full_name}."
      else
        flash[:notice] = "Welcome to Sleep Journey, #{@user.first_name}! A coach will be assigned to you soon."
      end
      redirect_to "/client/dashboard"
    else
      render :new_client, status: :unprocessable_entity
    end
  end

  def create_coach
    @user = User.new(user_params)
    @user.role = "coach"

    if @user.save
      session[:user_id] = @user.id
      flash[:notice] = "Welcome to Sleep Journey, #{@user.first_name}!"
      redirect_to "/coach/dashboard"
    else
      render :new_coach, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
  end

  def redirect_if_logged_in
    if current_user
      redirect_to dashboard_path_for(current_user.role)
    end
  end

  def dashboard_path_for(role)
    case role
    when "client"
      "/client/dashboard"
    when "coach"
      "/coach/dashboard"
    when "admin"
      "/admin/dashboard"
    else
      login_path
    end
  end
end
