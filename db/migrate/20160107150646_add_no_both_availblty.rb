class AddNoBothAvailblty < ActiveRecord::Migration
  def change
    add_column :available_dates, :no_both, :boolean, default: false
  end
end
