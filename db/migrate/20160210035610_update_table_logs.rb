class UpdateTableLogs < ActiveRecord::Migration
  def change
    remove_column :logs, :origin, :integer
    remove_column :logs, :latest, :integer
    add_column :logs, :category, :integer
    add_column :logs, :data, :text
  end
end
