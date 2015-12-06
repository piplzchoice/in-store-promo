class AddDataToStatement < ActiveRecord::Migration
  def change
    add_column :statements, :data, :text
  end
end
