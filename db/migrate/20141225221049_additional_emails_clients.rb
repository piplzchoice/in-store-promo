class AdditionalEmailsClients < ActiveRecord::Migration
  def change
    add_column :clients, :additional_emails, :text
  end
end
