class AddHideClientAndCoopClientReports < ActiveRecord::Migration
  def change
    add_column :reports, :hide_client_name, :boolean, default: false
    add_column :reports, :hide_client_product, :boolean, default: false
    add_column :reports, :hide_client_coop_name, :boolean, default: false
    add_column :reports, :hide_client_coop_product, :boolean, default: false    
  end
end
