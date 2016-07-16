class AddNoNeedSecondDateServices < ActiveRecord::Migration
  def change
    add_column :services, :no_need_second_date, :boolean, default: false 
  end
end
