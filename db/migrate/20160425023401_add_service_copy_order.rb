class AddServiceCopyOrder < ActiveRecord::Migration
  def change
    add_column :orders, :service_copy, :text
  end
end
