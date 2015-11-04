class AddInventoryServices < ActiveRecord::Migration
  def change
    add_column :services, :inventory_confirm, :boolean, default: false
    add_column :services, :inventory_date, :date
    add_column :services, :inventory_confirmed, :string
  end
end
