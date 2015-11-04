class ProductsServices < ActiveRecord::Migration
  def change
    create_table :products_services do |t|
      t.integer :product_id      
      t.integer :service_id      
    end       
  end
end