module Api
  module V1
    class DashboardController < Api::V1::BaseController
      ICONS = {
        "nutrition"    => "🥗",
        "supplements"  => "🍽️",
        "hypnosis"     => "🧘",
        "caffeine"     => "☕",
        "exercise"     => "💪"
      }.freeze

      def index
        render json: {
          message: "Welcome to your dashboard, #{current_user.first_name}!",
          user: {
            id: current_user.id,
            email: current_user.email,
            role: current_user.role,
            name: current_user.first_name,
            full_name: current_user.full_name,
            pillars: build_pillars,
            profile_picture_url: current_user.profile_picture.attached? ? url_for(current_user.profile_picture) : nil,
            coach: coach_info,
            oura_data: oura_data,
            active_plans: active_plans.as_json(only: %i[id wellness_pillar status details created_at])
          }
        }, status: :ok
      end

      private

      def build_pillars
        Plan.wellness_pillars.keys.map { |pillar| pillar_data_for(pillar) }
      end

      def pillar_data_for(pillar)
        plans = current_user.plans.where(wellness_pillar: pillar).order(created_at: :asc)
        total = plans.size
        completed = plans.reject { |p| p.status.in?(%w[created needs_resubmission]) }.size
        progress = total.positive? ? (completed * 100) / total : 0
        todays_task = plans.where(status: %w[created needs_resubmission]).last&.details

        {
          pillar: pillar,
          title: pillar.titleize,
          icon: ICONS[pillar],
          total: total,
          completed: completed,
          progress: progress,
          todays_task: todays_task
        }
      end

      def coach_info
        coach = current_user.coach
        return {} unless coach

        {
          id: coach.id,
          name: coach.full_name,
          email: coach.email,
          online: coach.online?,
          profile_picture_url: coach.profile_picture.attached? ? url_for(coach.profile_picture) : nil
        }
      end

      def oura_data
        return {} unless current_user.oura_access_token?

        begin
          oura = OuraClient.new(current_user)
          sleep_data = oura.sleep(start_date: Date.yesterday, end_date: Date.current)["data"] || []
          today = sleep_data.find { |d| d["day"] == Date.yesterday.to_s } || {}
          duration = today["total_sleep_duration"]
          formatted_duration = duration ? Time.at(duration).utc.strftime("%Hh %Mm") : nil

          {
            sleep_score: current_user.sleep_records.last&.score,
            sleep_duration: formatted_duration,
            sleep_efficiency: today["efficiency"]
          }
        rescue StandardError => e
          Rails.logger.warn("[Dashboard] Oura fetch failed: #{e.message}")
          {}
        end
      end

      def active_plans
        current_user.plans.where(status: %i[created needs_resubmission]).order(created_at: :asc)
      end
    end
  end
end
