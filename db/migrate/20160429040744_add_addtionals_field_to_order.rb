class AddAddtionalsFieldToOrder < ActiveRecord::Migration
  def change
      add_column :orders, :dot_number, :string
      add_column :orders, :product_sample, :string
      add_column :orders, :to_be_completed_by, :string
      add_column :orders, :distributor, :string
      add_column :orders, :comments, :text
  end
end
