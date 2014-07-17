class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.integer :service_id
      t.string :demo_in_store
      t.string :weather
      t.string :traffic
      t.string :busiest_hours
      t.string :price_comment
      t.string :sample_units_use
      t.timestamps
    end
  end
end
