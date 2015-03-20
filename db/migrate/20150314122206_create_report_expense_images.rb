class CreateReportExpenseImages < ActiveRecord::Migration
  def change
    create_table :report_expense_images do |t|
      t.integer :report_id
      t.string :file
      t.timestamps
    end
  end
end
