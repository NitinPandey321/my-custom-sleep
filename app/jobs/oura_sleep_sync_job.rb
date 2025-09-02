class OuraSleepSyncJob
  include Sidekiq::Job

  def perform
    date = Date.yesterday.to_s
    User.clients.find_each do |user|
      if user.oura_access_token
        oura = OuraClient.new(user)
        response = oura.sleep_scores(start_date: date, end_date: date)
        if response["data"].present?
          score = response["data"].first["score"]
          user.sleep_records.create!(
            date: date,
            score: score,
            raw_data: response["data"].first
          )
        end
      end
    end
  rescue => e
    Rails.logger.error("Oura sync failed for user #{user.id}: #{e.message}")
  end
end
