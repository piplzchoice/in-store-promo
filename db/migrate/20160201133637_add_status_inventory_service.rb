class AddStatusInventoryService < ActiveRecord::Migration
  def up
    add_column :services, :status_inventory, :boolean, :default => false
  end

  def down
    remove_column :services, :status_inventory
  end
end
