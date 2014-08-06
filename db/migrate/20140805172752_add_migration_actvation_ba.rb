class AddMigrationActvationBa < ActiveRecord::Migration
  def change
    add_column :brand_ambassadors, :is_active, :boolean, default: true
  end
end
