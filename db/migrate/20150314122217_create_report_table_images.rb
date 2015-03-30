class CreateReportTableImages < ActiveRecord::Migration
  def change
    create_table :report_table_images do |t|
      t.integer :report_id
      t.string :file
      t.timestamps
    end
  end
end
