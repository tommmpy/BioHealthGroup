class AddIndexesAndDefaults < ActiveRecord::Migration[8.0]
  def change
    add_index :sessions, :terminated_at
    change_column_default :branches, :enabled, from: nil, to: true
  end
end
