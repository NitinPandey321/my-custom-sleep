class OuraDashboardController < ApplicationController
  before_action :require_login
  before_action :set_client, only: [:dashboard_v2, :sleep_scores ]

  def sleep_scores
    range = params[:range]
    if range == "custom"
      start_date = Date.parse(params[:start]) rescue 15.days.ago.to_date
      end_date = Date.parse(params[:end]) rescue Date.current
    else
      days = range.to_i > 0 ? range.to_i : 7
      start_date = days.days.ago.to_date
      end_date = Date.current
    end

    records = @client.sleep_records
                     .where(date: start_date..end_date)
                     .order(:date)

    labels = records.pluck(:date).map { |d| d.strftime("%b %e") }
    sleep_scores = records.pluck(:score)

    render json: { labels: labels, sleep_scores: sleep_scores }
  end

  def dashboard_v2
    oura = OuraClient.new(@client)
    @sleep_metric = @client.sleep_metric
    records = @client.sleep_records
                        .where("date >= ?", 15.days.ago.to_date)
                        .order(:date)

    @sleep_scores = records.pluck(:score)
    @labels = records.pluck(:date).map { |d| d.strftime("%b %e") }
    todays_record = records.last
    @todays_score = todays_record&.score
    @sleep_data = oura.sleep(start_date: Date.yesterday, end_date: Date.current)["data"]
    @today_sleep = @sleep_data.find { |d| d["day"] == Date.yesterday.to_s }
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
