class AddStatusToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :status, :integer, default: 3, null: false
    add_column :users, :last_active_at, :datetime
  end
end
