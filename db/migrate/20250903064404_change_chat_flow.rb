class ChangeChatFlow < ActiveRecord::Migration[8.0]
  def change
    Conversation.destroy_all
    User.coaches.find_each do |coach|
      coach.clients.find_each do |client|
        Conversation.new_conversation(sender_id: coach.id, recipient_id: client.id)
      end
    end
    remove_reference :conversations, :sender, foreign_key: { to_table: :users }
    remove_reference :conversations, :recipient, foreign_key: { to_table: :users }
  end
end
