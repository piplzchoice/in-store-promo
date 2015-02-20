class AddClientProductsToReports < ActiveRecord::Migration
  def change
    add_column :reports, :client_products, :text
  end
end
