# app/controllers/api/v1/base_controller.rb
module Api
  module V1
    class BaseController < ApplicationController
      before_action :authenticate_user!
      skip_before_action :verify_authenticity_token

      private

      def authenticate_user!
        header = request.headers["Authorization"]
        token = header.split(" ").last if header
        decoded = JwtService.decode(token)
        if decoded && (user = User.find_by(id: decoded[:user_id]))
          @current_user = user
        else
          render json: { error: "Unauthorized" }, status: :unauthorized
        end
      end

      attr_reader :current_user
    end
  end
end
