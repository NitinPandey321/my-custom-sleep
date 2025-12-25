module Api
  module V1
    class GamificationController < BaseController
      include AchievementsHelper
      before_action :set_client

      def show
        user = @client
        current = current_level_info(user)
        nxt = next_level_info(user)
        progress_percent = [((user.on_time_weeks.to_f / 2) * 100), 100].min

        badges = rest_levels.map do |key, level|
          {
            key: key.to_s,
            title: level[:title],
            icon: level[:icon],
            earned: User.rest_levels[user.rest_level] >= User.rest_levels[key.to_s]
          }
        end

        render json: {
          rest_level: user.rest_level,
          current_level: current,
          next_level: nxt,
          on_time_weeks: user.on_time_weeks,
          progress_percent: progress_percent,
          badges: badges
        }
      end

      def set_client
        @client = if current_user.role == "coach"
                    current_user.clients.find(params[:client_id])
                  else
                    current_user
                  end
      end
    end
  end
end
