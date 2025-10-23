require "net/http"
require "uri"
require "json"

class OuraClient
  OURA_TOKEN_URL = "https://api.ouraring.com/oauth/token"
  BASE_URL = "https://api.ouraring.com/v2/usercollection"

  def initialize(user)
    @user = user
    @token = access_token
  end

  def access_token
    if @user.oura_expires_at < Time.current
      refresh!
    end
    @user.oura_access_token
  end

  def refresh!
    uri = URI(OURA_TOKEN_URL)
    res = Net::HTTP.post_form(uri, {
      grant_type:    "refresh_token",
      refresh_token: @user.oura_refresh_token,
      client_id:     ENV["OURA_CLIENT_ID"],
      client_secret: ENV["OURA_CLIENT_SECRET"]
    })

    data = JSON.parse(res.body)

    @user.update!(
      oura_access_token:  data["access_token"],
      oura_refresh_token: data["refresh_token"],
      oura_expires_at:    Time.current + data["expires_in"].to_i.seconds
    )
  end

  def sleep(start_date: 30.days.ago.to_date, end_date: Date.current)
    get("sleep", start_date:, end_date:)
  end

  def sleep_scores(start_date: 30.days.ago.to_date, end_date: Date.current)
    get("daily_sleep", start_date:, end_date:)
  end

  def sleep_time(start_date: 30.days.ago.to_date, end_date: Date.current)
    get("sleep_time", start_date:, end_date:)
  end

  def daily_stress(start_date: 30.days.ago.to_date, end_date: Date.current)
    get("daily_stress", start_date:, end_date:)
  end

  def activity(start_date: 30.days.ago.to_date, end_date: Date.current)
    get("daily_activity", start_date:, end_date:)
  end

  def readiness(start_date: 30.days.ago.to_date, end_date: Date.current)
    get("readiness", start_date:, end_date:)
  end

  def heart_rate(start_datetime: 2.hours.ago, end_datetime: Time.current)
    get("heartrate", start_datetime: start_datetime, end_datetime: end_datetime)
  end

  private

  def get(path, params = {})
    conn.get(path, params).body
  end

  def conn
    Faraday.new(BASE_URL) do |f|
      f.request :authorization, "Bearer", @token
      f.response :json
    end
  end
end
