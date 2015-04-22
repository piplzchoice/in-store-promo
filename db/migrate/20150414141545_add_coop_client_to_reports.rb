class AddCoopClientToReports < ActiveRecord::Migration
  def change
    add_column :reports, :client_coop_products, :text
  end
end
