class CreateServices < ActiveRecord::Migration
  def change
    create_table :services do |t|
      t.integer :project_id
      t.integer :location_id
      t.integer :brand_ambassador_id
      t.integer :user_id
      t.timestamps
    end
  end
end
