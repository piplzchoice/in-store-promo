class CreateBrandAmbassadorsLocations < ActiveRecord::Migration
  def change
    create_table :brand_ambassadors_locations do |t|
      t.integer :brand_ambassador_id
      t.integer :location_id      
    end
  end
end
