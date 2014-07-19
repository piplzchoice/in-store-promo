require "csv"
class ReportsController < ApplicationController
  before_filter :authenticate_user!
  authorize_resource class: ReportsController 

  def index
    respond_to do |format|
      format.html do
        @services = Service.all
        @brand_ambassadors = BrandAmbassador.all
        @projects = Project.all        
      end
      format.js do
        @services = Service.filter(params[:completed], params[:assigned_to], params[:client_name])
      end
      format.csv do
        @services = Service.filter(params[:completed], params[:assigned_to], params[:client_name])
        headers['Content-Disposition'] = "attachment; filename=\"report-#{Time.now.to_i}\""
        headers['Content-Type'] ||= 'text/csv'        
      end
    end
  end

  def show
    @report = Report.find(params[:id])
    @service = @report.service
  end

  def new
    @service = Service.find(params[:service_id])
    @report = @service.build_report
  end

  def create
    @report = Report.new(report_params)
    respond_to do |format|
      format.html do
        if @report.save
          redirect_to report_path(@report), notice: "Report created"
        else
          render :new
        end
      end
    end      
  end  

  def edit
    @report = Report.find(params[:id])
    @service = @report.service    
  end

  def update
    @report = Report.find(params[:id])
    @service = @report.service
    respond_to do |format|
      format.html do
        if @report.update_attributes(report_params)
          redirect_to report_path(@report), notice: "Report updated"
        else
          render :edit
        end
      end
    end          
  end

  def download_pdf
    file = "report-#{Time.now.to_i}.pdf"

    @report = Report.find(params[:id])
    @service = @report.service

    html = render_to_string(:layout => "print_report", :action => "print_pdf", :id => params[:id])
    kit = PDFKit.new(html)
    kit.stylesheets << "#{Rails.root}/app/assets/stylesheets/application.css.scss"
    send_data(kit.to_pdf, :filename => file, :type => 'application/pdf')    
  end

  def print_pdf
    @report = Report.find(params[:id])
    @service = @report.service
  end

  def report_params
    params.require(:report).permit(:service_id, :demo_in_store, :weather, :traffic, :busiest_hours, 
      :price_comment, :sample_units_use, :products, :product_one, :product_one_beginning, :product_one_end, 
      :product_one_sold, :product_two, :product_two_beginning, :product_two_end, :product_two_sold, :product_three, 
      :product_three_beginning, :product_three_end, :product_three_sold, :product_four, :product_four_beginning, 
      :product_four_end, :product_four_sold, :sample_product, :est_customer_touched, :est_sample_given, :expense_one, 
      :expense_one_img, :expense_two, :expense_two_img, :customer_comments, :price_value_comment, :ba_comments)
  end    
end