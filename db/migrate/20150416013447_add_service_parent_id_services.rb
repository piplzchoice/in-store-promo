class AddServiceParentIdServices < ActiveRecord::Migration
  def change
    add_column :services, :parent_id, :integer
  end
end
