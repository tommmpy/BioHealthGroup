class AddLastUrlToSessions < ActiveRecord::Migration[8.2]
  def change
    add_column :sessions, :last_url, :string
  end
end
