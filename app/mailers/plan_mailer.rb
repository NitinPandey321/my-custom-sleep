class PlanMailer < ApplicationMailer
  def plan_ready(user, plan)
    @user = user
    @pillar_name = plan.wellness_pillar
    @dashboard_url = root_url

    mail(
      to: @user.email,
      subject: "Your New #{@pillar_name} Strategy is Ready"
    )
  end

  def proof_upload_reminder(user, plan)
    @user = user
    @pillar_name = plan.wellness_pillar
    @upload_url = root_url # replace with deep link if available

    mail(
      to: @user.email,
      subject: "Action Required: 1 Hour Left to Upload Your Proof"
    )
  end

  def coach_proof_submission_notification(coach, plan, submission)
    @coach = coach
    @client = plan.user
    @pillar_name = plan.wellness_pillar
    @submitted_at = submission
    @dashboard_url = "#{ENV['BASE_URL']}/dashboards/coach"

    mail(
      to: @coach.email,
      subject: "Action Required: New Proof Submission from #{@client.full_name}"
    )
  end

  def achievement_unlocked(user, badge)
    @user = user
    @badge_name = badge[:title]
    @milestone = badge[:milestone_description]
    @total_badges = badge[:total_earned]
    @dashboard_url = "#{ENV['BASE_URL']}/dashboards/client"

    mail(
      to: @user.email,
      subject: "Achievement Unlocked: You’ve earned the #{@badge_name} Badge!"
    )
  end

  def coach_submission_overdue(plan)
    @coach = plan.user.coach
    @client = plan.user
    @pillar_name = plan.wellness_pillar
    @elapsed_hours = 4
    @dashboard_url = "#{ENV['BASE_URL']}/dashboards/coach"

    mail(
      to: @coach.email,
      subject: "URGENT: Submission Review Overdue (#{@elapsed_hours}-Hour Window)"
    )
  end

  def admin_sla_breach(plan)
    @admin = User.find_by(role: "admin")
    @coach = plan.user.coach
    @client = plan.user
    @pillar_name = plan.wellness_pillar
    @delay_hours = 24
    @dashboard_url = "#{ENV['BASE_URL']}/admin/dashboard"

    mail(
      to: @admin.email,
      subject: "SYSTEM ALERT: 24-Hour SLA Breach by Coach #{@coach.full_name}"
    )
  end
end
