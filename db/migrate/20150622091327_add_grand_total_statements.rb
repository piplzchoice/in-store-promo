class AddGrandTotalStatements < ActiveRecord::Migration
  def change
    add_column :statements, :grand_total, :decimal, :precision => 8, :scale => 2    
  end
end
