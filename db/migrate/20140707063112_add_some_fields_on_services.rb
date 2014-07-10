class AddSomeFieldsOnServices < ActiveRecord::Migration
  def change
    add_column :services, :start_at, :datetime
    add_column :services, :end_at, :datetime
    add_column :services, :details, :text
  end
end
