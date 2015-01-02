class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.integer :client_id
      t.string :service_ids
      t.text :line_items

      t.timestamps
    end
  end
end
