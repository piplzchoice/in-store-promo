class Add2MoreProductsReport < ActiveRecord::Migration
  def change
    add_column :reports, :product_five_sample, :integer
    add_column :reports, :product_five_price, :decimal, :precision => 8, :scale => 2        
    add_column :reports, :product_five, :string
    add_column :reports, :product_five_beginning, :integer
    add_column :reports, :product_five_end, :integer
    add_column :reports, :product_five_sold, :integer

    add_column :reports, :product_six_sample, :integer
    add_column :reports, :product_six_price, :decimal, :precision => 8, :scale => 2        
    add_column :reports, :product_six, :string
    add_column :reports, :product_six_beginning, :integer
    add_column :reports, :product_six_end, :integer
    add_column :reports, :product_six_sold, :integer    

    add_column :reports, :table_image_one_img, :string
    add_column :reports, :table_image_two_img, :string
  end
end
