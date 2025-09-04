class UsersController < ApplicationController
  before_action :redirect_if_logged_in, only: [ :role_selection, :new_client, :new_coach, :create_client, :create_coach ]
  before_action :require_login, only: [ :show, :edit, :update, :change_password ]
  before_action :set_user, only: [ :show, :edit, :update, :change_password ]
  before_action :parse_country_code, only: [ :create_client, :create_coach, :update ]

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
      assigned_coach = User.assign_coach_to_client(@user)
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

  def show
  end

  def edit
  end

  def update
    if @user.update(profile_params)
      flash[:notice] = "Profile updated successfully."
      redirect_to user_path(@user)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def change_password
    if @user.authenticate(params[:user][:current_password])
      if @user.update(password_params)
        redirect_to @user, notice: "Password updated successfully."
      else
        redirect_to "/users/#{@user.id}", alert: @user.errors.full_messages.join(", ")
      end
    else
      redirect_to @user, alert: "Current password is incorrect."
    end
  end

  private

  def set_user
    @user = current_user
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :country_code, :mobile_number, :phone_country_iso2)
  end

  def profile_params
    params.require(:user).permit(
      :first_name, :last_name, :email, :profile_picture,
      :country_code, :mobile_number
    )
  end

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def redirect_if_logged_in
    if current_user
      redirect_to dashboard_path_for(current_user.role)
    end
  end

  def parse_country_code
    if params[:user] && params[:user][:country_code]
      country_data = params[:user][:country_code].split('|')
      if country_data.length == 2
        params[:user][:country_code] = country_data[0]  # dial code like "+1"
        params[:user][:phone_country_iso2] = country_data[1]  # ISO2 code like "US"
      end
    end
  end
end
