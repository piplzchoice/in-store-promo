class ChangeColumnMilageBrandAmbassadors < ActiveRecord::Migration
  def change
    remove_column :brand_ambassadors, :mileage
    add_column :brand_ambassadors, :mileage, :boolean
  end
end
