class AddTokenToServices < ActiveRecord::Migration
  def change
    add_column :services, :token, :string
  end
end
