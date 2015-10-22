class AddOldServiceFlag < ActiveRecord::Migration
  def change
    add_column :services, :is_old_service, :boolean, default: true
  end
end
