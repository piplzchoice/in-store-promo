class AddTbsDataServices < ActiveRecord::Migration
  def down
    add_column :services, :tbs_data, :text
  end
end
