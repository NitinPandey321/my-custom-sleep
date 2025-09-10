class WeeklyGamificationService
  PROMOTION_THRESHOLD = 2 # 2 weeks on time
  DEMOTION_THRESHOLD = 2  # 2 weeks missed

  def initialize(user)
    @user = user
  end

  def check_week
    return unless @user.gamify?

    if submitted_on_time_this_week?
      handle_on_time_week
    else
      handle_missed_week
    end
  end

  private

  def submitted_on_time_this_week?
    weekly_plans = @user.plans.where("created_at >= ?", 1.week.ago)

    return false if weekly_plans.empty?

    weekly_plans.all? do |plan|
      plan.client_submitted_at.present? && plan.client_submitted_at <= plan.duration
    end
  end

  def handle_on_time_week
    @user.on_time_weeks += 1
    @user.missed_weeks = 0

    if @user.on_time_weeks >= PROMOTION_THRESHOLD && @user.rest_level_before_type_cast < User.rest_levels.values.max
      @user.rest_level = @user.rest_level_before_type_cast + 1
      @user.on_time_weeks = 0
      AuditLog.create!(user: @user, role: "client", action: :level_up, details: "Promoted to #{@user.level_name}", updated_by: @user.id)
    end

    @user.save!
  end

  def handle_missed_week
    @user.on_time_weeks = 0
    @user.missed_weeks += 1

    if @user.missed_weeks >= DEMOTION_THRESHOLD && @user.rest_level_before_type_cast > User.rest_levels.values.min
      @user.rest_level = @user.rest_level_before_type_cast - 1
      @user.missed_weeks = 0
      AuditLog.create!(user: @user, role: "client", action: :level_down, details: "Demoted to #{@user.level_name}", updated_by: @user.id)
    end

    @user.save!
  end
end
