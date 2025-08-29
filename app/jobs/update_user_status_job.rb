# app/jobs/update_user_status_job.rb
class UpdateUserStatusJob
  include Sidekiq::Job

  def perform
    User.clients.find_each do |user|
      update_status(user)
    end
  end

  private

  def update_status(user)
    plans = user.plans

    return if plans.empty?

    # Rule 1: needs_attention if any plan is needs_resubmission
    if plans.where(status: :needs_resubmission).exists?
      user.update!(status: :needs_attention)
      return
    end

    # Rule 2: falling_behind if any plan is not approved AND past due date
    if plans.where.not(status: :approved).where("duration < ?", Time.current).exists?
      user.update!(status: :falling_behind)
      return
    end

    # Rule 3: otherwise on_track (all plans approved on time or pending but not overdue)
    user.update!(status: :on_track)
  end
end
