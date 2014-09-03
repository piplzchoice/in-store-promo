class AddTravelExpenseReports < ActiveRecord::Migration
  def change
    add_column :reports, :travel_expense, :decimal, :precision => 8, :scale => 2
  end
end
