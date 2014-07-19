class AddTrafficAndSampleProductDefaultValues < ActiveRecord::Migration
  def change
    add_column :default_values, :traffic, :string
    add_column :default_values, :sample_product, :string
  end
end
