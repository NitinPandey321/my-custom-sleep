class Admin::PlansController < Admin::ApplicationController
  def index
    @users = User.clients.order(:first_name, :last_name)
    @plans = Plan.order(created_at: :desc)
    if params[:status].present?
      @plans = @plans.where(status: params[:status])
    end
    if params[:user_id].present?
      @plans = @plans.where(user_id: params[:user_id])
    end
  end

  def show
    @plan = Plan.find(params[:id])
  end
end
