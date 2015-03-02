class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.integer :client_id
      t.string :name
      t.timestamps
    end
  end
end
