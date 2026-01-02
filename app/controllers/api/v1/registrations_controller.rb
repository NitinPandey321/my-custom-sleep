module Api
  module V1
    class RegistrationsController < ApplicationController
      skip_before_action :verify_authenticity_token

      def create
        user = User.new(profile_params)

        if user.save
          User.assign_coach_to_client(user)
          token = JwtService.encode(user_id: user.id)
          render json: {
            message: "Account created successfully",
            token:,
            user: {
              id: user.id,
              email: user.email,
              role: user.role,
              name: user.first_name
            }
          }, status: :created
        else
          render json: { errors: format_errors(user.errors) },
                 status: :ok
        end
      end

      private

      def profile_params
        params.require(:user).permit(
          :first_name, :last_name, :email, :password, :password_confirmation,
          :profile_picture, :country_code, :mobile_number, :role,
          :gender, :preferred_coach_gender
        )
      end

      def format_errors(errors)
        errors.to_hash.transform_values { |msg| msg.join(", ") }
      end
    end
  end
end
