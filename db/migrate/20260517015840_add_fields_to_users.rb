class AddFieldsToUsers < ActiveRecord::Migration[8.2]
  def change
    add_column :users, :user_type, :integer
    add_column :users, :contacto_root, :string
  end
end
