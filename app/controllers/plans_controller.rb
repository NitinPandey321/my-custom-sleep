class PlansController < ApplicationController
  def create
    @plan = Plan.new(plan_params)
    if @plan.save
      redirect_to dashboards_coach_path, notice: "Plan created successfully!"
    else
      redirect_to dashboards_coach_path, alert: @plan.errors.full_messages.to_sentence
    end
  end

  def update
    @plan = Plan.find(params[:id])
    if @plan.update(plan_params)
      redirect_to dashboards_coach_path, notice: "Plan updated successfully!"
    else
      redirect_to dashboards_coach_path, alert: @plan.errors.full_messages.to_sentence
    end
  end

  def upload_proof
    @plan = Plan.find(params[:id])
    if params[:proof].present?
      @plan.proofs.attach(params[:proof])
      @plan.update(status: :pending)
      redirect_to dashboards_client_path, notice: "Proof uploaded and sent for approval."
    else
      redirect_to dashboards_client_path, alert: "Please select at least one image."
    end
  end

  def mark_done
    @plan = Plan.find(params[:id])
    if @plan.update(status: :pending)
      redirect_to dashboards_client_path, notice: "Plan marked as done"
    else
      redirect_to dashboards_client_path, alert: @plan.errors.full_messages.to_sentence
    end
  end


  def approve
    @plan = Plan.find(params[:id])
    @plan.update(status: :approved)
    redirect_to dashboards_coach_path, notice: "Plan approved."
  end

  def request_resubmission
    @plan = Plan.find(params[:id])
    if @plan.update(status: :needs_resubmission, resubmission_reason: params[:resubmission_reason])
      redirect_to dashboards_coach_path, notice: "Resubmission requested with reason."
    else
      redirect_to dashboards_coach_path, alert: @plan.errors.full_messages.to_sentence
    end
  end

  private

  def plan_params
    params.require(:plan).permit(:details, :wellness_pillar, :duration, :reminder_time, :user_id)
  end
end
