class AddStatusServices < ActiveRecord::Migration
  def change
    add_column :services, :status, :integer, default: 1 
  end
end
