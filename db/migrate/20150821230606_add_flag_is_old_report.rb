class AddFlagIsOldReport < ActiveRecord::Migration
  def change
    add_column :reports, :is_old_report, :boolean, default: true
  end
end
