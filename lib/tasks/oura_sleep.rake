# lib/tasks/oura_sleep.rake
namespace :oura_sleep do
  desc "Fetch last 30 days of Oura sleep data and recalc metrics"
  task fetch_last_30_days: :environment do
    User.clients.find_each do |user|
      next unless user.oura_access_token

      # Clear old data
      user.sleep_records.delete_all
      user.sleep_metric&.destroy

      start_date = 30.days.ago.to_date
      end_date   = Date.yesterday.to_date

      (start_date..end_date).each do |date|
        begin
          oura = OuraClient.new(user)
          response = oura.sleep_scores(start_date: date.to_s, end_date: date.to_s)

          next unless response["data"].present?

          record_data = response["data"].first
          score = record_data["score"]

          sleep_record = user.sleep_records.find_or_initialize_by(date: date)
          sleep_record.update!(
            score: score,
            raw_data: record_data
          )
        rescue => e
          Rails.logger.error("Oura sync failed for user #{user.id} on #{date}: #{e.message}")
        end
      end

      # Recalculate metrics after all records are inserted
      SleepMetricsCalculatorService.new(user).calculate!
    end

    puts "Oura sleep sync completed for last 30 days."
  end
end
