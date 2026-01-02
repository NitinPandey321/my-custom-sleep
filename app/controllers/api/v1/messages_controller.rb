module Api
  module V1
    class MessagesController < Api::V1::BaseController
      before_action :set_conversation

      # GET /api/v1/conversations/:conversation_id/messages
      def index
        messages = @conversation.messages.includes(:user).order(:created_at)
        messages.where.not(user_id: current_user.id).update_all(read_at: Time.current)

        render json: messages.last(50).map { |m| message_json(m) }
      end

      # POST /api/v1/conversations/:conversation_id/messages
      def create
        message = @conversation.messages.new(
          body: params[:body],
          user: current_user
        )

        if message.save
          ActionCable.server.broadcast(
            "conversation_#{@conversation.id}",
            {
              type: "new_message",
              message: message_json(message)
            }
          )

          @conversation.users.each do |user|
            ActionCable.server.broadcast(
              "user_#{user.id}_conversations",
              {
                type: "conversation_updated",
                conversation: conversation_json(@conversation, user)
              }
            )
          end

          render json: message_json(message), status: :created
        else
          render json: { error: message.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def conversation_json(conversation, viewer)
        other = conversation.users.where.not(id: viewer.id).first
        last_message = conversation.messages.last

        {
          id: conversation.id,
          participant: {
            id: other&.id,
            name: other&.full_name,
            role: other&.role,
            online: other&.online?,
            profile_picture_url: other&.profile_picture.attached? ? url_for(other.profile_picture) : nil
          },
          last_message: last_message&.body,
          last_message_at: last_message&.created_at,
          unread_count: viewer.unread_messages_count(other)
        }
      end

      def set_conversation
        @conversation = Conversation.find(params[:conversation_id])
      end

      def message_json(message)
        {
          id: message.id,
          body: message.body,
          user_id: message.user_id,
          user_name: message.user.full_name,
          created_at: message.created_at,
          mine: message.user_id == current_user.id
        }
      end
    end
  end
end
