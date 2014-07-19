class ReportsController < ApplicationController
  before_filter :authenticate_user!
  authorize_resource class: ReportsController 

  def index
    # if current_user.has_role?(:admin) || current_user.has_role?(:ismp)
    #   @services = Service.all
    # else
    #   @services = current_user.brand_ambassador.services
    # end    
    @services_grid = initialize_grid(Service,
      :name => 'grid',
      :enable_export_to_csv => true,
      :csv_field_separator => ';',
      :csv_file_name => 'services'      
    )

    export_grid_if_requested('grid' => 'grid')
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