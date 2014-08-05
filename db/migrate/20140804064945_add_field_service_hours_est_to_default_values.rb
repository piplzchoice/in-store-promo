class AddFieldServiceHoursEstToDefaultValues < ActiveRecord::Migration
  def change
    add_column :default_values, :service_hours_est, :integer
  end
end
