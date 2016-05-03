class StatementsController < ApplicationController
  before_filter :authenticate_user!
  authorize_resource class: StatementsController

  def index
    @brand_ambassador = BrandAmbassador.find(params[:brand_ambassador_id])
    respond_to do |format|
      format.html do
        @statements = @brand_ambassador.statements.paginate(:page => 1)
      end
      format.js do
        @statements = @brand_ambassador.statements.paginate(:page => params[:page])
      end
    end
  end

  def show
    @brand_ambassador = BrandAmbassador.find(params[:brand_ambassador_id])
    @statement = @brand_ambassador.statements.find(params[:id])
    @services = @brand_ambassador.services.find(@statement.services_ids)
    @totals_ba_paid = @brand_ambassador.services.calculate_total_ba_paid(@statement.services_ids)
  end

  def download
    brand_ambassador = BrandAmbassador.find(params[:brand_ambassador_id])
    statement = brand_ambassador.statements.find(params[:id])
    send_data(File.read(statement.file.path), :filename => statement.file.path.split("/").last, :type => 'application/pdf')
  end

  def export_data
    @brand_ambassador = BrandAmbassador.find(params[:brand_ambassador_id])
    @statements = @brand_ambassador.statements.paginate(:page => 1)

    fields = [
      "Date",
      "Total Paid",
      "Expenses Included",
      "Addtional Items"
    ]

    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet :name => 'Data'
    sheet1.row(0).replace fields

    @statements.each_with_index do |statement, i|
      sheet1.row(i + 1).replace statement.export_data
    end

    export_file_path = [Rails.root, "tmp", "export-statement-data-#{Time.now.to_i}.xls"].join("/")
    book.write export_file_path
    send_file export_file_path, :content_type => "application/vnd.ms-excel", :disposition => 'inline'
  end

end
