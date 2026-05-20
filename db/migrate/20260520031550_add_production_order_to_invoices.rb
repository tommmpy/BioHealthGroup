class AddProductionOrderToInvoices < ActiveRecord::Migration[8.2]
  def change
    add_reference :invoices, :production_order, foreign_key: true
    remove_reference :invoices, :estudio, foreign_key: true
  end
end
