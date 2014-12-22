class AddFileToInvoice < ActiveRecord::Migration
  def change
    add_column :invoices, :file, :string
  end
end
