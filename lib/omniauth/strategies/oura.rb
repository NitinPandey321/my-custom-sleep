require "omniauth-oauth2"

module OmniAuth
  module Strategies
    class Oura < OmniAuth::Strategies::OAuth2
      option :name, "oura"
      option :client_options, {
        site: "https://api.ouraring.com",
        authorize_url: "https://cloud.ouraring.com/oauth/authorize",
        token_url: "https://api.ouraring.com/oauth/token"
      }

      uid          { raw_info["sub"] }
      info         { { email: raw_info["email"], name: raw_info["name"] } }
      extra        { { raw_info: raw_info } }
      def raw_info
        @raw_info ||= access_token.get("/v2/userinfo").parsed
      end
    end
  end
end
