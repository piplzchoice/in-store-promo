class AddTbsDataServices < ActiveRecord::Migration
  def change
    add_column :services, :tbs_data, :text
  end
end
