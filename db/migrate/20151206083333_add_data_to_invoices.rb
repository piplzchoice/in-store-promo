class AddDataToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :data, :text
  end
end
