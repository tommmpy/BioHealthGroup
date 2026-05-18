class RemoveOldBranchFieldFromUsers < ActiveRecord::Migration[8.2]
  def change
    remove_column :users, :branch, :string
  end
end
