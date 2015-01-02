class AddGrandTotalInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :grand_total, :decimal, :precision => 8, :scale => 2    
  end
end
