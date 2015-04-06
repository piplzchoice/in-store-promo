class AddTerorrityToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :territory_id, :integer
  end
end
