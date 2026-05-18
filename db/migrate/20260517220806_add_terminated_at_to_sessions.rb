class AddTerminatedAtToSessions < ActiveRecord::Migration[8.2]
  def change
    add_column :sessions, :terminated_at, :datetime
  end
end
