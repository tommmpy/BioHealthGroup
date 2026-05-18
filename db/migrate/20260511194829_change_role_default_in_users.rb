class ChangeRoleDefaultInUsers < ActiveRecord::Migration[8.2]
  def change
    change_column_default :users, :role, from: nil, to: 0
  end
end
