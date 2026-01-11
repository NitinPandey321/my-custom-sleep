class PasswordsController < ApplicationController
  before_action :redirect_if_logged_in
  before_action :find_user_by_email, only: [ :verify_otp, :edit, :update ]
  before_action :validate_otp_session, only: [ :edit, :update ]

  # Step 1: Show email form
  def new
  end

  # Step 1: Handle email submission, generate OTP, send email
  def create
    @user = User.find_by(email: params[:email]&.downcase)

    if @user
      # Clear any existing OTP attempts
      @user.clear_reset_password_otp!

      # Generate new OTP
      otp = @user.generate_reset_password_otp

      # Send OTP email
      UserMailer.send_reset_password_otp(@user, otp).deliver_now

      # Store email in session for next steps
      session[:reset_password_email] = @user.email

      redirect_to verify_otp_form_passwords_path, notice: "OTP sent to your email. Please check your inbox."
    else
      redirect_to new_password_path,
              alert: "Email not registered. Please check your email address."
    end
  end

  # Step 2: Show OTP verification form
  def verify_otp_form
    redirect_to new_password_path, alert: "Please start the password reset process again." unless session[:reset_password_email]
  end

  # Step 2: Handle OTP verification
  def verify_otp
    otp_input = params[:otp]

    if @user.reset_password_attempts_exceeded?
      @user.clear_reset_password_otp!
      session.delete(:reset_password_email)
      redirect_to new_password_path, alert: "Too many failed attempts. Please start over."
      return
    end

    if @user.reset_password_otp_expired?
      @user.clear_reset_password_otp!
      session.delete(:reset_password_email)
      redirect_to new_password_path, alert: "OTP has expired. Please request a new one."
      return
    end

    if @user.reset_password_otp_valid?(otp_input)
      # OTP is valid, redirect to password reset form
      session[:otp_verified] = true
      redirect_to edit_password_path(@user), notice: "OTP verified successfully. Please set your new password."
    else
      # Increment failed attempts
      @user.increment_reset_password_attempts!
      remaining_attempts = 5 - @user.reset_password_attempts

      if remaining_attempts > 0
        flash.now[:alert] = "Invalid OTP. You have #{remaining_attempts} attempts remaining."
        render :verify_otp_form
      else
        @user.clear_reset_password_otp!
        session.delete(:reset_password_email)
        redirect_to new_password_path, alert: "Too many failed attempts. Please start over."
      end
    end
  end

  # Step 3: Show password reset form
  def edit
    @user = User.find(params[:id])
  end

  # Step 3: Handle password update
  def update
    @user = User.find(params[:id])

    password = params[:user][:password]
    password_confirmation = params[:user][:password_confirmation]

    if password != password_confirmation
      flash.now[:alert] = "Passwords do not match."
      render :edit
      return
    end

    if password.blank? || password.length < 6
      flash.now[:alert] = "Password must be at least 6 characters long."
      render :edit
      return
    end

    if @user.update(password: password, password_confirmation: password_confirmation)
      # Clear OTP and session data
      @user.clear_reset_password_otp!
      session.delete(:reset_password_email)
      session.delete(:otp_verified)

      redirect_to login_path, notice: "Password successfully reset. Please log in with your new password."
    else
      flash.now[:alert] = "Failed to update password. Please try again."
      render :edit
    end
  end

  # Resend OTP
  def resend_otp
    if session[:reset_password_email]
      @user = User.find_by(email: session[:reset_password_email])
      if @user
        # Generate new OTP
        otp = @user.generate_reset_password_otp

        # Send OTP email
        UserMailer.send_reset_password_otp(@user, otp).deliver_now

        redirect_to verify_otp_form_passwords_path, notice: "New OTP sent to your email."
      else
        session.delete(:reset_password_email)
        redirect_to new_password_path, alert: "Session expired. Please start over."
      end
    else
      redirect_to new_password_path, alert: "Please start the password reset process."
    end
  end

  private

  def redirect_if_logged_in
    if logged_in?
      redirect_to dashboard_path_for(current_user.role), notice: "You are already logged in."
    end
  end

  def find_user_by_email
    unless session[:reset_password_email]
      redirect_to new_password_path, alert: "Please start the password reset process."
      return
    end

    @user = User.find_by(email: session[:reset_password_email])
    unless @user
      session.delete(:reset_password_email)
      redirect_to new_password_path, alert: "Session expired. Please start over."
    end
  end

  def validate_otp_session
    unless session[:otp_verified]
      redirect_to verify_otp_form_passwords_path, alert: "Please verify your OTP first."
    end
  end

  def dashboard_path_for(role)
    case role
    when "client"
      client_dashboard_path
    when "coach"
      coach_dashboard_path
    when "admin"
      admin_dashboard_path
    else
      login_path
    end
  end
end
