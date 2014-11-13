class CreateStatements < ActiveRecord::Migration
  def change
    create_table :statements do |t|
      t.integer :brand_ambassador_id
      t.string :file
      t.string :state_no

      t.timestamps
    end
  end
end
