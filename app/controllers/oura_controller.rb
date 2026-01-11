# app/controllers/oura_controller.rb
class OuraController < ApplicationController
  before_action :require_login

  def connect
    redirect_to "https://cloud.ouraring.com/oauth/authorize?response_type=code" \
                "&client_id=#{ENV['OURA_CLIENT_ID']}" \
                "&redirect_uri=#{CGI.escape(oura_callback_url)}" \
                "&scope=email personal daily heartrate workout tag session spo2", allow_other_host: true
  end

  def callback
    if params[:error]
      render plain: "Error: #{params[:error_description]}", status: :unprocessable_entity
      return
    end

    conn = Faraday.new(url: "https://api.ouraring.com") do |f|
      f.request :url_encoded
      f.response :json
    end
    response = conn.post("/oauth/token", {
      grant_type: "authorization_code",
      code: params[:code],
      redirect_uri: oura_callback_url,
      client_id: ENV["OURA_CLIENT_ID"],
      client_secret: ENV["OURA_CLIENT_SECRET"]
    })

    token_data = response.body
    if token_data["access_token"].present?
      # Save token for current user
      current_user.update!(
        oura_access_token:  token_data["access_token"],
        oura_refresh_token: token_data["refresh_token"],
        oura_expires_at:    Time.current + token_data["expires_in"].to_i.seconds
      )

      OuraBaselineSyncJob.perform_later(current_user.id)
      UserMailer.oura_connected(current_user).deliver_later
      redirect_to dashboards_client_path, notice: "Oura connected!"
    else
      render plain: "Token exchange failed: #{token_data.inspect}", status: :unprocessable_entity
    end
  end
end
