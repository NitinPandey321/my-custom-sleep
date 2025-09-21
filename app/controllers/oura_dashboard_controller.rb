class OuraDashboardController < ApplicationController
  before_action :require_login
  before_action :set_client, only: [ :index ]

  def index
    oura = OuraClient.new(@client)

    # Fetch sleep data
    @sleep_data = oura.sleep["data"]
    @today_sleep = @sleep_data.find { |d| d["day"] == Date.yesterday.to_s }
    @recent_sleep = @sleep_data.reverse

    # Fetch sleep scores
    @sleep_scores = oura.sleep_scores["data"]
    @today_score = @sleep_scores.find { |d| d["day"] == Date.yesterday.to_s }
    @recent_scores = @sleep_scores.reverse

    # Fetch stress data
    @stress_data = oura.daily_stress(start_date: Date.yesterday, end_date: Date.current)["data"].last

    # Fetch heart rate data
    @heart_rate_data = oura.heart_rate(start_datetime: 12.hours.ago.iso8601, end_datetime: Time.current.iso8601)["data"].last(100)
  end

  def dashboard_v2
    # This is a frontend-only dashboard for now
    # Future: Add real Oura data integration here
  end

  private

  def set_client
    @client = if current_user.role == "coach"
                current_user.clients.find(params[:client_id])
    else
                current_user
    end
  end
end
