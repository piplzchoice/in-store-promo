class CreateBrandAmbassadors < ActiveRecord::Migration
  def change
    create_table :brand_ambassadors do |t|
      t.integer :user_id
      t.string :name
      t.string :phone
      t.string :address
      t.integer :grade
      t.decimal :rate, precision: 5, scale: 2
      t.integer :mileage
      t.timestamps
    end
  end
end
