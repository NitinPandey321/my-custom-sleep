module Api
  module V1
    class PasswordsController < Api::V1::BaseController
      skip_before_action :authenticate_user!
      before_action :find_user, only: [:send_otp, :verify_otp, :reset]

      # Step 1: Send OTP
      def send_otp
        @user.clear_reset_password_otp!
        otp = @user.generate_reset_password_otp
        UserMailer.send_reset_password_otp(@user, otp).deliver_now

        render json: { message: "OTP sent to email." }, status: :ok
      end

      # Step 2: Verify OTP
      def verify_otp
        otp_input = params[:otp]

        if @user.reset_password_attempts_exceeded?
          @user.clear_reset_password_otp!
          return render json: { error: "Too many failed attempts." }, status: 422
        end

        if @user.reset_password_otp_expired?
          @user.clear_reset_password_otp!
          return render json: { error: "OTP expired." }, status: 422
        end

        unless @user.reset_password_otp_valid?(otp_input)
          @user.increment_reset_password_attempts!
          attempts_left = 5 - @user.reset_password_attempts
          return render json: { error: "Invalid OTP", attempts_left: attempts_left }, status: 422
        end

        # OTP valid → issue a temporary token
        token = SecureRandom.hex(20)
        Rails.cache.write("reset_password_token_#{token}", @user.id, expires_in: 15.minutes)

        render json: {
          message: "OTP verified.",
          reset_token: token
        }, status: :ok
      end

      # Step 3: Reset password
      def reset
        token = params[:reset_token]
        user_id = Rails.cache.read("reset_password_token_#{token}")

        return render json: { error: "Invalid or expired token" }, status: 422 unless user_id

        @user = User.find(user_id)

        unless params[:password] == params[:password_confirmation]
          return render json: { error: "Passwords do not match." }, status: 422
        end

        if params[:password].length < 6
          return render json: { error: "Password must be at least 6 characters" }, status: 422
        end

        if @user.update(password: params[:password])
          @user.clear_reset_password_otp!
          Rails.cache.delete("reset_password_token_#{token}")

          render json: { message: "Password reset successfully." }, status: :ok
        else
          render json: { error: @user.errors.full_messages }, status: 422
        end
      end

      private

      def find_user
        @user = User.find_by(email: params[:email]&.downcase)
        return render json: { error: "Account not found" }, status: :ok unless @user
      end
    end
  end
end
