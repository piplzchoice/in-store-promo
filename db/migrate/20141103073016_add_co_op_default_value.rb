class AddCoOpDefaultValue < ActiveRecord::Migration
  def change
    add_column :default_values, :co_op_price, :decimal, :precision => 8, :scale => 2
  end
end
