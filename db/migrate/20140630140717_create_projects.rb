class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.integer :user_id
      t.integer :client_id
      t.string :name
      t.string :descriptions
      t.timestamps
    end
  end
end
