class PlansController < ApplicationController
  def create
    @plan = current_user.plans.new(plan_params)
    if @plan.save
      redirect_to dashboards_coach_path, notice: "Plan created successfully!"
    else
      redirect_to dashboards_coach_path, alert: @plan.errors.full_messages.to_sentence
    end
  end

  private

  def plan_params
    params.require(:plan).permit(:details, :wellness_pillar, :duration, :reminder_time)
  end
end
