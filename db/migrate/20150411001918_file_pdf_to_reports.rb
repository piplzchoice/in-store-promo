class FilePdfToReports < ActiveRecord::Migration
  def change
    add_column :reports, :file_pdf, :string
  end
end
