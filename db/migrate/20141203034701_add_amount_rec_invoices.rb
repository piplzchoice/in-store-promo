class AddAmountRecInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :amount_received, :decimal, :precision => 8, :scale => 2    
    add_column :invoices, :date_received, :date
  end
end
