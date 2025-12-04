module Api
  module V1
    class SessionsController < ApplicationController
      skip_before_action :verify_authenticity_token

      def create
        email = params[:email]&.downcase
        password = params[:password]
        user = User.find_by(email:)

        if user.nil?
          render json: { errors: { email: "No account found with this email" } },
                 status: :ok
        elsif !user.authenticate(password)
          render json: { errors: { password: "Incorrect password" } },
                 status: :ok
        else
          token = JwtService.encode(user_id: user.id)
          render json: {
            token:,
            user: user_response(user)
          }, status: :ok
        end
      end

      private

      def user_response(user)
        {
          id: user.id,
          email: user.email,
          name: user.first_name,
          first_name: user.first_name,
          last_name: user.last_name,
          gender: user.gender,
          preferred_coach_gender: user.preferred_coach_gender,
          mobile_number: user.mobile_number,
          country_code: user.country_code,
          phone_country_iso2: user.phone_country_iso2,
          profile_picture_url: user.profile_picture.attached? ? url_for(user.profile_picture) : nil,
          role: user.role
        }
      end
    end
  end
end
