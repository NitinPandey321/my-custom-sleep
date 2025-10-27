class ActivityLogsController < ApplicationController
  before_action :require_login

  def create
    seconds = params[:seconds].to_i.clamp(10, 300) # protect from abuse
    UserActivityLog.log_activity(current_user, seconds)
    head :ok
  end
end
