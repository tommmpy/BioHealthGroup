class AddBranchToUsers < ActiveRecord::Migration[8.2]
  def change
    add_reference :users, :branch, null: false, foreign_key: true
  end
end
