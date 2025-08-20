class AddCoachToUsers < ActiveRecord::Migration[8.0]
  def change
    add_reference :users, :coach, null: true, foreign_key: { to_table: :users }
  end
end
