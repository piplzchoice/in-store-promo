class AddServicesIdsToStatements < ActiveRecord::Migration
  def change
    add_column :statements, :services_ids, :text
  end
end
