class AddAlertMarkServices < ActiveRecord::Migration
  def change
    add_column :services, :alert_sent, :boolean, default: false
    add_column :services, :alert_sent_date, :datetime
    add_column :services, :alert_sent_admin, :boolean, default: false
    add_column :services, :alert_sent_admin_date, :datetime
  end
end
