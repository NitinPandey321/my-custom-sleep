module Api
  module V1
    class OuraController < Api::V1::BaseController
      before_action :set_client

      def index
        oura = OuraClient.new(@client)
        sleep_metric = @client.sleep_metric
        improvement = (sleep_metric&.improvement || 0).to_f

        records = @client.sleep_records
                        .where("date >= ?", 21.days.ago.to_date)
                        .order(date: :desc)

        labels = records.pluck(:date).map { |d| d.strftime("%-m/%-d") }
        sleep_scores = records.pluck(:score)
        todays_score = records.last&.score

        sleep_data = (oura.sleep(start_date: Date.yesterday, end_date: Date.current) rescue {})["data"] || []
        today_sleep = sleep_data.find { |d| d["day"] == Date.yesterday.to_s } || {}

        program_status = compute_program_status(improvement)

        render json: {
          sleep_metric: {
            baseline_score: sleep_metric&.baseline_score,
            baseline_duration: sleep_metric&.baseline_duration,
            current_avg_score: sleep_metric&.current_avg_score,
            current_duration: sleep_metric&.current_duration,
            improvement: improvement.round(2),
            improvement_display: format_improvement(improvement)
          },
          chart: {
            labels: labels,
            sleep_scores: sleep_scores,
            baseline_score: sleep_metric&.baseline_score
          },
          program_status: program_status,
          today: {
            score: todays_score,
            sleep: {
              date: today_sleep["day"],
              total_sleep_duration_seconds: today_sleep["total_sleep_duration"],
              total_sleep_duration_human: human_duration(today_sleep["total_sleep_duration"]),
              efficiency: today_sleep["efficiency"],
              average_heart_rate: today_sleep["average_heart_rate"],
              deep_sleep_duration_seconds: today_sleep["deep_sleep_duration"],
              deep_sleep_duration_human: human_duration(today_sleep["deep_sleep_duration"]),
              light_sleep_duration_seconds: today_sleep["light_sleep_duration"],
              light_sleep_duration_human: human_duration(today_sleep["light_sleep_duration"]),
              rem_sleep_duration_seconds: today_sleep["rem_sleep_duration"],
              rem_sleep_duration_human: human_duration(today_sleep["rem_sleep_duration"]),
              average_breath: today_sleep["average_breath"]
            }
          }
        }
      end

      private

      def set_client
        @client = if current_user.role == "coach"
                    current_user.clients.find(params[:client_id])
        else
                    current_user
        end
      end

      def human_duration(seconds)
        return nil unless seconds.present?
        secs = seconds.to_i
        hours = secs / 3600
        minutes = (secs % 3600) / 60
        "#{hours}h #{minutes}m"
      end

      def format_improvement(value)
        sign = value > 0 ? "+" : ""
        "#{sign}#{value.round(1)}%"
      end

      def compute_program_status(improvement)
        case improvement
        when -Float::INFINITY...10
          { status: "needs_attention", label: "🚨 Needs Attention", progress_to_25: [ (improvement / 25.0 * 100).round, 100 ].min, progress_color: "#ef4444" }
        when 10...25
          { status: "on_the_way", label: "⚠️ On the Way", progress_to_25: [ (improvement / 25.0 * 100).round, 100 ].min, progress_color: "#f59e42" }
        when 25...50
          { status: "great_progress", label: "🌟 Great Progress", progress_to_50: [ (improvement / 50.0 * 100).round, 100 ].min, progress_color: "#22c55e" }
        else
          { status: "outstanding", label: "🏆 Outstanding", progress_to_50: 100, progress_color: "#2563eb" }
        end
      end
    end
  end
end
