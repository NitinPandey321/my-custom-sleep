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

      def coach_dashboard
        clients = coach_clients
        today = Date.current
        plans = Plan.where(user: clients).where("Date(duration) <= ?", today)
                                         .where.not(status: :approved)
                                         .order(duration: :desc)
        todays_due_and_overdue_plans = plans.map do |plan|
          {
            id: plan.id,
            user_name: plan.user.full_name,
            details: plan.details,
            status: plan.status,
            due_time: plan.duration.strftime("%I:%M %p, %d %b")
          }
        end

        todays_plans_count = todays_due_and_overdue_plans.count

        completed_plans_count = Plan.where(user: clients, status: :approved).count

        unread_chat_count = clients.sum do |client|
          current_user.unread_messages_count(client)
        end

        clients_progress = clients.map do |client|
          plans = client.plans
          total = plans.count
          completed = plans.where(status: :approved).count
          percentage = total.positive? ? (completed * 100) / total : 0

          {
            name: client.full_name,
            percentage: percentage
          }
        end

        render json: {
          user: {
            name: current_user.full_name.presence || current_user.first_name,
            email: current_user.email,
            role: current_user.role
          },
          active_clients: clients.count,
          todays_plans: todays_plans_count,
          completed_plans: completed_plans_count,
          unread_chat_count: unread_chat_count,
          todays_due_plans: todays_due_and_overdue_plans,
          clients_progress: clients_progress
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

      def coach_clients
        current_user.clients
      end
    end
  end
end
