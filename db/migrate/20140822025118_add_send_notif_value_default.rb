class AddSendNotifValueDefault < ActiveRecord::Migration
  def change
    add_column :default_values, :send_unrespond, :integer
  end
end
