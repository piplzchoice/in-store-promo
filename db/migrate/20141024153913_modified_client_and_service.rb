class ModifiedClientAndService < ActiveRecord::Migration
  def change
    add_column :clients, :rate, :decimal, :precision => 8, :scale => 2    
    add_column :services, :client_id, :integer
    remove_column :services, :user_id, :integer
  end
end
