class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.integer :client_id
      t.string :number
      t.integer :status, default: 0
      t.timestamps
    end

    create_table :locations_orders do |t|
      t.integer :location_id
      t.integer :order_id
    end

    add_column :services, :order_id, :integer, default: 0
  end
end
