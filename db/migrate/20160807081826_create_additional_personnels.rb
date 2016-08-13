class CreateAdditionalPersonnels < ActiveRecord::Migration
  def change
    create_table :additional_personnels do |t|
      t.integer :user_id
      t.integer :client_id
      t.integer :account_id
      t.string :name      
      t.timestamps
    end
  end
end
