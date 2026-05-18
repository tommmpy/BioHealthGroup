class CreateProcessSteps < ActiveRecord::Migration[8.2]
  def change
    create_table :process_steps do |t|
      t.integer :step_number
      t.string :title
      t.text :description
      t.string :icon
      t.boolean :active

      t.timestamps
    end
  end
end
