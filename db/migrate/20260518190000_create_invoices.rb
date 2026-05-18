class CreateInvoices < ActiveRecord::Migration[8.0]
  def change
    create_table :invoices do |t|
      t.references :user, null: false, foreign_key: true
      t.references :estudio, null: true, foreign_key: true
      t.string :invoice_number, null: false
      t.integer :status, default: 0
      t.decimal :subtotal, precision: 12, scale: 2, null: false
      t.decimal :tax_rate, precision: 5, scale: 2, default: 0
      t.decimal :tax_amount, precision: 12, scale: 2, default: 0
      t.decimal :total, precision: 12, scale: 2, null: false
      t.date :due_date, null: false
      t.datetime :paid_at
      t.text :notes
      t.timestamps
    end
    add_index :invoices, :invoice_number, unique: true
  end
end
