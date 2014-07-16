class AddColumnAmAndPmAvailableDates < ActiveRecord::Migration
  def change
    add_column :available_dates, :am, :boolean, default: false
    add_column :available_dates, :pm, :boolean, default: false
  end
end
