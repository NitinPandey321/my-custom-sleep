module AchievementsHelper
  REST_LEVELS = {
    rest_resident: { icon: "🌙", title: "Rest Resident" },
    sleep_scholar: { icon: "📚", title: "Sleep Scholar" },
    circadian_champion: { icon: "🏆", title: "Circadian Champion" },
    chief_rest_officer: { icon: "👑", title: "Chief Rest Officer" },
    recovery_luminary: { icon: "⭐", title: "Recovery Luminary" }
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
