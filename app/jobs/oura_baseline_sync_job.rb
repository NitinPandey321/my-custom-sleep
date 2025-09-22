class OuraBaselineSyncJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)
    return unless user.oura_access_token

    start_date = 15.days.ago.to_date
    end_date   = Date.yesterday.to_date

    oura = OuraClient.new(user)
    response = oura.sleep_scores(start_date: start_date.to_s, end_date: end_date.to_s)

    return unless response["data"].present?

    response["data"].each do |record|
      date  = record["day"] || record["date"] || record["summary_date"] # depends on API field
      score = record["score"]

      next if date.blank? || score.blank?

      user.sleep_records.find_or_initialize_by(date: date).update!(
        score: score,
        raw_data: record
      )
    end

    SleepMetricsCalculatorService.new(user).calculate!
  rescue => e
    Rails.logger.error("Oura baseline sync failed for user #{user.id}: #{e.message}")
  end
end
