class AddMoreFieldInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :number, :string
    add_column :invoices, :issue_date, :date
    add_column :invoices, :terms, :string
    add_column :invoices, :po, :string
  end
end
