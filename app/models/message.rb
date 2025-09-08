class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :user

  validates :body, presence: true

  after_create_commit do
    broadcast_append_to conversation,
      target: "messages_#{conversation.id}",
      partial: "messages/message",
      locals: { message: self }

    recipient = conversation.other_participant(user)
    broadcast_replace_to "user_#{recipient.id}",
      target: "unread_count_user_#{conversation_id}_#{recipient.id}",
      partial: "conversations/unread_badge",
      locals: { conversation: conversation, viewer: recipient }
  end

  after_create_commit :update_response_times
  after_create_commit :mark_conversation_started
  after_create_commit :schedule_escalation_check, if: -> { user.client? }

  private

  def schedule_escalation_check
    ChatEscalationJob.perform_later(id)
  end

  def update_response_times
    last_msg = conversation.messages.where.not(user_id: user_id).order(created_at: :desc).first
    return unless last_msg

    response_time = created_at - last_msg.created_at

    update_conversation_avg(response_time)
    update_user_avg(response_time)
  end

  def update_conversation_avg(response_time)
    conv = conversation
    conv.avg_response_time = rolling_average(conv.avg_response_time, response_time)
    conv.save!
  end

  def update_user_avg(response_time)
    u = user
    u.avg_response_time = rolling_average(u.avg_response_time, response_time)
    u.save!
  end

  def rolling_average(old_avg, new_value)
    return new_value if old_avg == 0
    (old_avg + new_value) / 2.0
  end

  def mark_conversation_started
    if conversation.messages.count == 1
      AuditLog.create!(
        user: user,
        role: user.role,
        auditable: conversation,
        action: :conversation_started,
        details: "Conversation started by #{user.full_name} at #{created_at}"
      )
    end
  end
end
