class AddDeletedAtToSomeTables < ActiveRecord::Migration
  def change
    [:users, :services, :reports, :projects, :locations, :clients].each do |table|
      add_column table, :is_active, :boolean, default: true
    end
  end
end
