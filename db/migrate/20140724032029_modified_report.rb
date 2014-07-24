class ModifiedReport < ActiveRecord::Migration
  def change
    add_column :reports, :product_one_price, :decimal, :precision => 8, :scale => 2
    add_column :reports, :product_two_price, :decimal, :precision => 8, :scale => 2
    add_column :reports, :product_three_price, :decimal, :precision => 8, :scale => 2
    add_column :reports, :product_four_price, :decimal, :precision => 8, :scale => 2

    add_column :reports, :product_one_sample, :integer
    add_column :reports, :product_two_sample, :integer
    add_column :reports, :product_three_sample, :integer
    add_column :reports, :product_four_sample, :integer    
    
    remove_column :reports, :price_comment, :string
    remove_column :reports, :sample_units_use, :string
    remove_column :reports, :price_value_comment, :decimal, :precision => 8, :scale => 2
    remove_column :reports, :expense_one, :string
    remove_column :reports, :expense_two, :string

    add_column :reports, :expense_one, :decimal, :precision => 8, :scale => 2, default: 0
    add_column :reports, :expense_two, :decimal, :precision => 8, :scale => 2, default: 0
  end
end