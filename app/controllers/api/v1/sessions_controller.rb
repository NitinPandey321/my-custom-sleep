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
            user: {
              id: user.id,
              email: user.email,
              role: user.role,
              name: user.first_name
            }
          }, status: :ok
        end
      end
    end
  end
end
