module AchievementsHelper
  REST_LEVELS = {
    rest_resident: { icon: "🌙", title: "Rest Resident", total_earned: 1, milestone_description: "Complete 1 plan" },
    sleep_scholar: { icon: "📚", title: "Sleep Scholar", total_earned: 2, milestone_description: "Complete 2 plans" },
    circadian_champion: { icon: "🏆", title: "Circadian Champion", total_earned: 3, milestone_description: "Complete 3 plans" },
    chief_rest_officer: { icon: "👑", title: "Chief Rest Officer", total_earned: 4, milestone_description: "Complete 4 plans" },
    recovery_luminary: { icon: "⭐", title: "Recovery Luminary", total_earned: 5, milestone_description: "Complete 5 plans" }
  }

  def rest_levels
    REST_LEVELS
  end

  def current_level_info(user)
    REST_LEVELS[user.rest_level.to_sym]
  end

  def next_level_info(user)
    levels = user.class.rest_levels.keys
    idx = levels.index(user.rest_level)
    next_key = levels[idx + 1]
    next_key ? REST_LEVELS[next_key.to_sym] : nil
  end
end
