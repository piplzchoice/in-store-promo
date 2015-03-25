class AddTerorrityToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :terorrity_id, :integer
  end
end
