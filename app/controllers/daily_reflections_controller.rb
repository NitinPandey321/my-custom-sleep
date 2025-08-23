class DailyReflectionsController < ApplicationController
  def show
    @reflection = current_user.daily_reflections.find_by(reflection_date: Date.today)
  end

  def create
    @reflection = current_user.daily_reflections.new(reflection_params)
    @reflection.reflection_date = Date.today
    if @reflection.save
      redirect_to dashboards_client_path, notice: "Reflection saved!"
    else
      redirect_to dashboards_client_path, alert: "Could not save reflection."
    end
  end

  private

  def reflection_params
    params.require(:daily_reflection).permit(:mood, :note)
  end
end
