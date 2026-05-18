class CreatePayments < ActiveRecord::Migration[8.0]
  def change
    create_table :payments do |t|
      t.references :invoice, null: false, foreign_key: true
      t.decimal :amount, precision: 12, scale: 2, null: false
      t.integer :payment_method, default: 0
      t.string :reference
      t.datetime :paid_at, null: false
      t.text :notes
      t.timestamps
    end
  end
end
