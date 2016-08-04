class AddMoreContacts < ActiveRecord::Migration
  def change
    add_column :locations, :more_contacts, :text, default: nil
  end
end
