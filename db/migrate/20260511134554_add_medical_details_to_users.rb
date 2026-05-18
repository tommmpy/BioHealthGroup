class AddMedicalDetailsToUsers < ActiveRecord::Migration[8.2]
  def change
    add_column :users, :ci, :string
    add_column :users, :phone_number, :string
    add_column :users, :branch, :string
    add_column :users, :address, :string
  end
end
