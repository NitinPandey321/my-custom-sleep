class Admin::AuditLogsController < Admin::ApplicationController
  def index
    @users = User.order(:first_name, :last_name)
    @audit_logs = AuditLog.order(created_at: :desc)

    if params[:user_id].present?
      user = User.find_by(id: params[:user_id])
      user_ids = [ user.id ]
      user_ids << user.coach_id if user.role == "client"
      @audit_logs = @audit_logs.where(user_id: user_ids)
    end
  end
end
