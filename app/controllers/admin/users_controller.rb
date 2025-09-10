class Admin::UsersController < Admin::ApplicationController
  before_action :set_user, only: [ :show, :edit, :update ]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to admin_user_path(@user), notice: "User was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def index
    @users = User.order(:created_at)
    if params[:role].present?
      @users = @users.where(role: params[:role])
    end
  end

  def show
  end

  def edit
    load_assignments
  end

  def update
    if @user.update(user_params)
      update_assignments
      redirect_to admin_user_path(@user), notice: "User updated successfully."
    else
      flash.now[:alert] = "Failed to update user."
      load_assignments
      render :edit
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(
      :first_name,
      :last_name,
      :email,
      :status,
      :role,
      :deactivated,
      :coach_id,
      :password,
      :password_confirmation,
      client_ids: [],
    )
  end

  # preload lists for form
  def load_assignments
    @coaches = User.where(role: "coach", deactivated: false)
    @clients = User.where(role: "client", deactivated: false)
  end

  # handle coach-client assignment logic
  def update_assignments
    if @user.coach?
      @user.client_ids = params[:user][:client_ids].reject(&:blank?)
    elsif @user.client?
      @user.update(coach_id: params[:user][:coach_id])
    end
  end
end
