class ChangePrecisionRateBrandAmbassadors < ActiveRecord::Migration
  def change
    remove_column :brand_ambassadors, :rate
    add_column :brand_ambassadors, :rate, :decimal, :precision => 8, :scale => 2
  end
end
