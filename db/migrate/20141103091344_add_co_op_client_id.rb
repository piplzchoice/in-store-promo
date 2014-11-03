class AddCoOpClientId < ActiveRecord::Migration
  def change
    add_column :services, :co_op_client_id, :integer
  end
end
