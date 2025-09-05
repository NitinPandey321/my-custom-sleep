class AddPhoneE164ToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :phone_e164, :string
    add_index :users, :phone_e164
    add_column :users, :phone_country_iso2, :string
  end
end
