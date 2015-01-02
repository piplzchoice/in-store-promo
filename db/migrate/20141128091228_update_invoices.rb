class UpdateInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :rate_total_all, :decimal, :precision => 8, :scale => 2    
    add_column :invoices, :expsense_total_all, :decimal, :precision => 8, :scale => 2    
    add_column :invoices, :travel_total_all, :decimal, :precision => 8, :scale => 2    
    add_column :invoices, :grand_total_all, :decimal, :precision => 8, :scale => 2    
  end
end