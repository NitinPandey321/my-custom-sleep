class CreateConversationParticipants < ActiveRecord::Migration[8.0]
  def change
    create_table :conversation_participants do |t|
      t.references :conversation, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :role, null: false, default: 0
      t.timestamps
    end
  end
end
