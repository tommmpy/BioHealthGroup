class AddBirthdayToUsers < ActiveRecord::Migration[8.2]
  def change
    add_column :users, :birthday, :date
  end
end
