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

    parse_country_code if params[:user][:country_code].present?

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
      respond_to do |format|
        format.html { render :new_client, status: :unprocessable_entity }
        format.json { render json: { errors: format_validation_errors(@user.errors) }, status: :unprocessable_entity }
      end
    end
  end

  def create_coach
    @user = User.new(user_params)
    @user.role = "coach"

    parse_country_code if params[:user][:country_code].present?

    if @user.save
      session[:user_id] = @user.id
      flash[:notice] = "Welcome to Sleep Journey, #{@user.first_name}!"
      redirect_to "/coach/dashboard"
    else
      respond_to do |format|
        format.html { render :new_coach, status: :unprocessable_entity }
        format.json { render json: { errors: format_validation_errors(@user.errors) }, status: :unprocessable_entity }
      end
    end
  end

  def show
  end

  def edit
  end

  def update
    if params[:user][:email].present? && params[:user][:email] != @user.email
      @user.unverified_email = params[:user][:email]
      @user.generate_email_verification_token!
      EmailService.send_verification_email(@user, @user.unverified_email)
      flash[:notice] = "Verification email sent to #{@user.unverified_email}. Please verify to update your email."
      redirect_to user_path(@user)
    elsif @user.update(profile_params.except(:email))
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

  def verify_email
    user = User.find_by(email_verification_token: params[:token])
    if user && user.unverified_email.present?
      user.email = user.unverified_email
      user.unverified_email = nil
      user.email_verification_token = nil
      user.save!
      flash[:notice] = "Email updated and verified successfully."
    else
      flash[:alert] = "Invalid or expired verification link."
    end
    redirect_to user_path(user || current_user)
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
    if params[:user][:country_code].include?("|")
      dial_code, iso2 = params[:user][:country_code].split("|")
      @user.country_code = dial_code
      @user.phone_country_iso2 = iso2
    end
  end

  def format_validation_errors(errors)
    formatted_errors = {}
    errors.each do |error|
      field_name = case error.attribute.to_s
      when "first_name" then "firstName"
      when "last_name" then "lastName"
      when "mobile_number" then "phone"
      when "country_code" then "phone"
      when "phone_e164" then "phone"
      when "phone_country_iso2" then "phone"
      when "password_confirmation" then "passwordConfirmation"
      else error.attribute.to_s.camelcase(:lower)
      end

      # For phone-related errors, we want to show the most user-friendly message
      if [ "mobile_number", "country_code", "phone_e164", "phone_country_iso2" ].include?(error.attribute.to_s)
        formatted_errors["phone"] = error.message
      else
        formatted_errors[field_name] = error.message
      end
    end
    formatted_errors
  end

  def parse_country_code
    if params[:user] && params[:user][:country_code]
      country_data = params[:user][:country_code].split("|")
      if country_data.length == 2
        params[:user][:country_code] = country_data[0]  # dial code like "+1"
        params[:user][:phone_country_iso2] = country_data[1]  # ISO2 code like "US"
      end
    end
  end
end
