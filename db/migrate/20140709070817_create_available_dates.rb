class CreateAvailableDates < ActiveRecord::Migration
  def change
    create_table :available_dates do |t|
      t.integer :brand_ambassador_id
      t.date :availablty
      t.timestamps
    end
  end
end
