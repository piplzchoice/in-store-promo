class CreateLogs < ActiveRecord::Migration
  def change
    create_table :logs do |t|
      t.integer :service_id
      t.integer :origin
      t.integer :latest
      t.timestamps
    end
  end
end
