class CreateDefaultValues < ActiveRecord::Migration
  def change
    create_table :default_values do |t|
      t.decimal :rate_project, precision: 8, scale: 2
      t.timestamps
    end
  end
end
