class AddLineItemsStatements < ActiveRecord::Migration
  def change
    add_column :statements, :line_items, :text
  end
end
