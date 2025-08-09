class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :password_digest
      t.string :role
      t.string :profile_image
      t.boolean :onboarding_completed, default: false

      t.timestamps
    end
    add_index :users, :email, unique: true
  end
end
