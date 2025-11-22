module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    protected

    def find_verified_user
      # If you are using JWT
      if request.params[:token].present?
        token = request.params[:token]
        decoded = JWT.decode(token, Rails.application.secret_key_base)[0]
        User.find(decoded["user_id"])
      else
        session_key = Rails.application.config.session_options[:key]
        raw_session = cookies.encrypted[session_key] ||
                      cookies.signed[session_key]

        if raw_session.present? && raw_session["user_id"]
          User.find_by(id: raw_session["user_id"])
        end
      end
    rescue
      reject_unauthorized_connection
    end
  end
end
