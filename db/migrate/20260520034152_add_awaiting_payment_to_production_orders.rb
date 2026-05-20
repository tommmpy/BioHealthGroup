class AddAwaitingPaymentToProductionOrders < ActiveRecord::Migration[8.2]
  def change
    create_table :production_tasks do |t|
      t.references :production_order, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :assigned_role, null: false, default: 0
      t.boolean :completed, default: false
      t.datetime :completed_at
      t.references :completed_by, foreign_key: { to_table: :users }
      t.integer :position, null: false, default: 0
      t.timestamps
    end

    add_index :production_tasks, [ :production_order_id, :position ]
  end
end
