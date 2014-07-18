class AddMoreReports < ActiveRecord::Migration
  def change
    add_column :reports, :products, :string
    add_column :reports, :product_one, :string
    add_column :reports, :product_one_beginning, :integer
    add_column :reports, :product_one_end, :integer
    add_column :reports, :product_one_sold, :integer
    add_column :reports, :product_two, :string
    add_column :reports, :product_two_beginning, :integer
    add_column :reports, :product_two_end, :integer
    add_column :reports, :product_two_sold, :integer
    add_column :reports, :product_three, :string
    add_column :reports, :product_three_beginning, :integer
    add_column :reports, :product_three_end, :integer
    add_column :reports, :product_three_sold, :integer 
    add_column :reports, :product_four, :string
    add_column :reports, :product_four_beginning, :integer
    add_column :reports, :product_four_end, :integer
    add_column :reports, :product_four_sold, :integer
    add_column :reports, :sample_product, :string
    add_column :reports, :est_customer_touched, :string
    add_column :reports, :est_sample_given, :string
    add_column :reports, :expense_one, :string
    add_column :reports, :expense_one_img, :string
    add_column :reports, :expense_two, :string
    add_column :reports, :expense_two_img, :string
    add_column :reports, :customer_comments, :text
    add_column :reports, :price_value_comment, :decimal, :precision => 8, :scale => 2
  end
end
