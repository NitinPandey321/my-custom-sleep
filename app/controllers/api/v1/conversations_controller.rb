module Api
  module V1
    class ConversationsController < Api::V1::BaseController
      before_action :set_conversation, only: 
      [:show, :escalate, :dismiss, :accept_request, :dismiss_request, :mark_as_read]

      # GET /api/v1/conversations
      def index
        conversations = current_user.conversations
          .includes(:users, :messages)
          .order("messages.created_at DESC NULLS LAST")

        render json: conversations.map { |c| conversation_json(c) }
      end

      # GET /api/v1/conversations/:id
      def show
        authorize_conversation!

        render json: {
          conversation: conversation_json(@conversation),
          participants: @conversation.conversation_participants.map do |p|
            {
              id: p.user.id,
              name: p.user.full_name,
              role: p.role
            }
          end
        }
      end

      # POST /api/v1/conversations
      def create
        conversation = Conversation.between(current_user.id, params[:recipient_id]).first

        unless conversation
          conversation = Conversation.create!
          conversation.conversation_participants.create!(user: current_user, role: :client)
          conversation.conversation_participants.create!(
            user_id: params[:recipient_id],
            role: User.find(params[:recipient_id]).coach? ? :coach : :client
          )
        end

        render json: conversation_json(conversation), status: :created
      end

      # POST /api/v1/conversations/:id/escalate
      def escalate
        client = @conversation.conversation_participants.role_client.first&.user

        ActionCable.server.broadcast(
          "user_#{client.id}_mobile",
          { type: "ESCALATION_WAITING" }
        )

        Turbo::StreamsChannel.broadcast_update_to(
          "user_#{client.id}",
          target: "escalation_popup",
          partial: "conversations/escalation_waiting"
        )
        User.coaches.where.not(id: @conversation.coach.id).each do |coach|
          ActionCable.server.broadcast(
            "user_#{coach.id}_mobile",
            {
              type: "NEW_REQUEST",
              conversation_id: @conversation.id,
              client_name: client.full_name
            }
          )

          Turbo::StreamsChannel.broadcast_append_to(
            "user_#{coach.id}",
            target: "coach_requests",
            partial: "conversations/coach_request",
            locals: { conversation: @conversation, client: @conversation.users.where(role: :client).first }
          )
        end

        render json: { status: "escalated" }, status: :ok
      end

      # POST /api/v1/conversations/:id/dismiss
      def dismiss
        client = @conversation.conversation_participants.role_client.first&.user

        ActionCable.server.broadcast(
          "user_#{client.id}_mobile",
          { type: "DISMISS_ESCALATION" }
        )

        Turbo::StreamsChannel.broadcast_update_to(
          "user_#{client.id}",
          target: "escalation_popup",
          html: "" # empties the frame
        )
        render json: { status: "dismissed" }, status: :ok
      end

      # POST /api/v1/conversations/:id/accept_request
      def accept_request
        client_id = @conversation.users.where(role: :client).first.id
        unless @conversation.conversation_participants.exists?(user: current_user)
          @conversation.conversation_participants.create!(
            user: current_user,
            role: :temp_coach
          )
        end

        User.coaches.where.not(id: @conversation.coach.id).each do |coach|
          Turbo::StreamsChannel.broadcast_update_to(
            "user_#{coach.id}",
            target: "coach_request_#{@conversation.id}",
            html: "" # clears request card but keeps container alive
          )

          ActionCable.server.broadcast(
            "user_#{coach.id}_mobile",
            { type: "DISMISS_ESCALATION" }
          )
        end

        Turbo::StreamsChannel.broadcast_update_to(
          "user_#{client_id}",
          target: "escalation_popup",
          partial: "conversations/new_coach_joined",
          locals: { coach: current_user }
        )

        ActionCable.server.broadcast(
          "user_#{client_id}_mobile",
          { type: "COACH_JOINED" }
        )

        message = @conversation.messages.create!(
          user: current_user,
          body: "Coach #{current_user.full_name} has joined the conversation."
        )

        broadcast_message(message)

        render json: { status: "accepted" }, status: :ok
      end

      # POST /api/v1/conversations/:id/dismiss_request
      def dismiss_request
        ActionCable.server.broadcast(
          "user_#{current_user.id}_mobile",
          {
            type: "DISMISS_REQUEST",
            conversation_id: @conversation.id
          }
        )

        Turbo::StreamsChannel.broadcast_update_to(
          "user_#{current_user.id}",
          target: "coach_request_#{params[:id]}",
          html: "" # clears request card for this coach only
        )

        render json: { status: "dismissed" }
      end

      # POST /api/v1/conversations/:id/mark_as_read
      def mark_as_read
        @conversation.messages
                     .where.not(user_id: current_user.id)
                     .update_all(read_at: Time.current)

        render json: { status: "read" }
      end

      private

      def set_conversation
        @conversation = Conversation.find(params[:id])
      end

      def authorize_conversation!
        unless @conversation.users.include?(current_user)
          render json: { error: "Unauthorized" }, status: :forbidden
        end
      end

      def conversation_json(conversation)
        other = conversation.users.where.not(id: current_user.id).first
        last_message = conversation.messages.first

        {
          id: conversation.id,
          participant: {
            id: other&.id,
            name: other&.full_name,
            role: other&.role,
            online: other&.online?,
            profile_picture_url: other&.profile_picture.attached? ? url_for(other.profile_picture) : nil,
          },
          last_message: last_message&.body,
          last_message_at: last_message&.created_at,
          unread_count: current_user.unread_messages_count(other)
        }
      end

      def broadcast_message(message)
        ActionCable.server.broadcast(
          "conversation_#{message.conversation_id}",
          {
            type: "new_message",
            message: {
              id: message.id,
              body: message.body,
              user_id: message.user_id,
              created_at: message.created_at
            }
          }
        )
      end
    end
  end
end
