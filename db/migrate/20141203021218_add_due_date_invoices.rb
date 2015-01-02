class AddDueDateInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :due_date, :date
  end
end
