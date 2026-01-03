module Api
  module V1
    class UsersController < Api::V1::BaseController
      def index
        render json: { error: "Unauthorized" }, status: :unauthorized and return unless current_user.coach?
        users = current_user.clients
        render json: users.map { |user| user_response(user) }, status: :ok
      end

      # GET /api/v1/user
      def show
        render json: user_response(current_user), status: :ok
      end

      # PUT /api/v1/user
      def update
        user = current_user

        parse_country_code if params[:user][:country_code].present?

        # Handle email change → goes to unverified_email + sends verification email
        if params[:user][:email].present? && params[:user][:email] != user.email
          user.unverified_email = params[:user][:email]
          user.generate_email_verification_token!
          EmailService.send_verification_email(user, user.unverified_email)

          user.save!

          return render json: {
            message: "Verification email sent. Please verify to update email."
          }, status: :ok
        end

        # Normal update (except email)
        if user.update(user_update_params.except(:email))
          render json: { message: "Profile updated successfully.", user: user_response(user) }, status: :ok
        else
          render json: { errors: format_errors(user.errors) }, status: 422
        end
      end

      # PUT /api/v1/user/change_password
      def change_password
        user = current_user

        unless user.authenticate(params[:current_password])
          return render json: { error: "Current password is incorrect." }, status: 422
        end

        if params[:password] != params[:password_confirmation]
          return render json: { error: "Passwords do not match." }, status: 422
        end

        if params[:password].length < 6
          return render json: { error: "Password must be at least 6 characters." }, status: 422
        end

        if user.update(password: params[:password])
          render json: { message: "Password updated successfully." }, status: :ok
        else
          render json: { errors: format_errors(user.errors) }, status: 422
        end
      end

      def destroy
        user = current_user
        clients = user.clients.to_a

        User.transaction do
          user.destroy!
        end
        clients.each do |client|
          client.reload
          User.assign_coach_to_client(client)
        end
        render json: { message: "Account deleted successfully." }, status: :ok
      end

      private

      def user_update_params
        params.require(:user).permit(
          :first_name, :last_name, :profile_picture,
          :country_code, :mobile_number, :gender, :preferred_coach_gender, :email
        )
      end

      def user_response(user)
        {
          id: user.id,
          email: user.email,
          name: user.first_name,
          full_name: user.full_name,
          first_name: user.first_name,
          last_name: user.last_name,
          gender: user.gender,
          preferred_coach_gender: user.preferred_coach_gender,
          mobile_number: user.mobile_number,
          country_code: user.country_code,
          phone_country_iso2: user.phone_country_iso2,
          profile_picture_url: user.profile_picture.attached? ? url_for(user.profile_picture) : nil,
          role: user.role,
          oura_connected: user.oura_access_token.present?,
          latest_sleep_score: user.sleep_records.last&.score
        }
      end

      # Convert "+91|IN" → "+91", "IN"
      def parse_country_code
        data = params[:user][:country_code].split("|")
        if data.length == 2
          params[:user][:country_code] = data[0]
          params[:user][:phone_country_iso2] = data[1]
        end
      end

      def format_errors(errors)
        errors.to_hash.transform_values { |msg| msg.join(", ") }
      end
    end
  end
end
