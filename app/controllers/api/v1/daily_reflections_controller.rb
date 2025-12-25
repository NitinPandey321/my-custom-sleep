module Api
  module V1
    class DailyReflectionsController < BaseController
      before_action :set_client

      def show
        reflection = @client.today_reflection
        mood_options = DailyReflection::MOODS.map { |key, label| { key: key, label: label } }

        if reflection
          render json: { reflection: reflection.as_json(only: [:id, :mood, :note, :reflection_date]), mood_options: mood_options }
        else
          render json: { reflection: nil, mood_options: mood_options }
        end
      end

      def create
        reflection = current_user.daily_reflections.new(reflection_params)
        reflection.reflection_date = Date.current
        if reflection.save
          render json: reflection.as_json(only: [:id, :mood, :note, :reflection_date]), status: :created
        else
          render json: { errors: reflection.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def reflection_params
        params.require(:daily_reflection).permit(:mood, :note)
      end

      def set_client
        @client = if current_user.role == "coach"
                    current_user.clients.find(params[:client_id])
                  else
                    current_user
                  end
      end
    end
  end
end
