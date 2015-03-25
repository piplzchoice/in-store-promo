class CreateTerritories < ActiveRecord::Migration
  def change
    create_table :territories do |t|
      t.string :name

      t.timestamps
    end

    create_table :brand_ambassadors_territories do |t|
      t.integer :brand_ambassador_id
      t.integer :territory_id
    end    

  end
end
