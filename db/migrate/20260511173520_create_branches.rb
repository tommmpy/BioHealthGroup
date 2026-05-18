class CreateBranches < ActiveRecord::Migration[8.2]
  def change
    create_table :branches do |t|
      t.string :name
      t.string :address
      t.string :phone
      t.boolean :enabled

      t.timestamps
    end
  end
end
