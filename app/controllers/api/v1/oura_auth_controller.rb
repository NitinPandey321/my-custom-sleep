module Api
  module V1
    class Api::V1::OuraAuthController < Api::V1::BaseController
      skip_before_action :authenticate_user!, only: [ :callback, :connect ]

      def session
        token = SecureRandom.hex(32)
        Rails.cache.write("oura_link_#{token}", current_user.id, expires_in: 10.minutes)
        render json: {
          url: "/v1/oura_auth/connect?session=#{token}"
        }
      end

      def connect
        cache_key = "oura_link_#{params[:session]}"
        user_id = Rails.cache.read(cache_key)

        return render json: { error: "expired" }, status: 401 unless user_id

        current_user = User.find(user_id)

        state = JwtService.encode({ user_id: current_user.id }, 10.minutes.from_now)
        Rails.cache.delete(cache_key)

        redirect_to "https://cloud.ouraring.com/oauth/authorize?" \
                    "response_type=code" \
                    "&client_id=#{ENV['OURA_CLIENT_ID']}" \
                    "&redirect_uri=#{CGI.escape(callback_api_v1_oura_auth_index_url)}" \
                    "&scope=email personal daily heartrate workout tag session spo2" \
                    "&state=#{state}",
                    allow_other_host: true
      end

      def callback
        begin
          decoded = JwtService.decode(params[:state])
          user = User.find(decoded[:user_id])
        rescue
          return redirect_to "sleepcoach://oura?status=error&message=invalid_state",  allow_other_host: true
        end

        conn = Faraday.new(url: "https://api.ouraring.com") do |f|
          f.request :url_encoded
          f.response :json
        end
        response = conn.post("/oauth/token", {
          grant_type: "authorization_code",
          code: params[:code],
          redirect_uri: callback_api_v1_oura_auth_index_url,
          client_id: ENV["OURA_CLIENT_ID"],
          client_secret: ENV["OURA_CLIENT_SECRET"]
        })

        if response.body["access_token"].present?
          user.update!(
            oura_access_token: response.body["access_token"],
            oura_refresh_token: response.body["refresh_token"],
            oura_expires_at: Time.current + response.body["expires_in"].to_i.seconds
          )

          OuraBaselineSyncJob.perform_later(user.id)
          UserMailer.oura_connected(user).deliver_later

          redirect_to "sleepcoach://oura?status=success", allow_other_host: true
        else
          redirect_to "sleepcoach://oura?status=error&message=token_failed", allow_other_host: true
        end
      end
    end
  end
end
