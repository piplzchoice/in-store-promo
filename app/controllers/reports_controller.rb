require "csv"
class ReportsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_role, except: [:index, :view_calendar, :show, :download_pdf, :print_pdf]
  helper_method :sort_column, :sort_direction
  authorize_resource class: ReportsController 

  def index
    respond_to do |format|
      format.html do
        if current_user.has_role?(:admin) || current_user.has_role?(:ismp)
          @services = Service.all.order(start_at: :desc).paginate(:page => params[:page])
          @brand_ambassadors = BrandAmbassador.all
          @clients = Client.all
          @projects = Project.all        
        elsif current_user.has_role?(:client)
          @services = current_user.client.services.order(created_at: :desc).where(services: {status: 2}).paginate(:page => params[:page])
          @brand_ambassadors = @services.collect{|x| x.brand_ambassador }.flatten.uniq
        else
          @services = current_user.brand_ambassador.services.order(created_at: :desc).paginate(:page => params[:page])
        end        
      end
      
      format.js do
        ba_id = (current_user.has_role?(:admin) || current_user.has_role?(:ismp) || current_user.has_role?(:client) ? params[:assigned_to] : current_user.brand_ambassador.id)
        
        client_name = ""
        if current_user.has_role?(:admin) || current_user.has_role?(:ismp)
          client_name = params[:client_name]
        elsif current_user.has_role?(:client)
          client_name = current_user.client.id
        end
        
        project_name = (current_user.has_role?(:admin) || current_user.has_role?(:ismp) ? params[:project_name] : "")
        @services = Service.filter_and_order(params[:status], ba_id, client_name, project_name, sort_column, sort_direction).paginate(:page => params[:page])
      end

      format.csv do
        ba_id = (current_user.has_role?(:admin) || current_user.has_role?(:ismp) || current_user.has_role?(:client) ? params[:assigned_to] : current_user.brand_ambassador.id)
        
        client_name = ""
        if current_user.has_role?(:admin) || current_user.has_role?(:ismp)
          client_name = params[:client_name]
        elsif current_user.has_role?(:client)
          client_name = current_user.client.id
        end
        
        project_name = (current_user.has_role?(:admin) || current_user.has_role?(:ismp) ? params[:project_name] : "")
        
        @services = Service.filter_and_order(params[:status], ba_id, params[:client_name], params[:project_name], sort_column, sort_direction)
        
        headers['Content-Type'] ||= 'text/csv'
        headers['Content-Disposition'] = "attachment; filename=\"report-#{Time.now.to_i}.csv\""           
      end
    end
  end

  def ba_payments    
    respond_to do |format|
      format.html do
        @brand_ambassadors = BrandAmbassador.all
        @services = Service.all.where({status: Service.status_paid}).order(start_at: :desc)
      end    

      format.js do
        ba_id = params[:assigned_to]
        project_name = ""
        @services = Service.filter_and_order(Service.status_paid, ba_id, "", project_name, sort_column, sort_direction)
      end
    end    
  end

  def process_ba_payments
    unless params[:service_ids].nil?
      hash_data = BrandAmbassador.process_payments(params[:service_ids])
      hash_data.each_key do |key|
        @ba = BrandAmbassador.find(key)
        @services = @ba.services.find(hash_data[key])
        @totals_ba_paid = Service.calculate_total_ba_paid(hash_data[key])
        Service.update_to_ba_paid(hash_data[key])

        file = "ba-#{@ba.id}-paid-#{Time.now.to_i}.pdf"

        html = render_to_string(:layout => "print_report", :action => "print_process_ba_payments", :id => key, service_ids: hash_data[key].join("-"))
        kit = PDFKit.new(html)
        kit.stylesheets << "#{Rails.root}/app/assets/stylesheets/application.css.scss"      
        ApplicationMailer.ba_is_paid(@ba, kit.to_pdf).deliver
      end      
    end
    redirect_to ba_payments_reports_path    
  end

  def print_process_ba_payments
    @ba = BrandAmbassador.find(params[:id])
    @services = @ba.services.find(params[:service_ids].split("-"))
    @totals_ba_paid = @ba.services.calculate_total_ba_paid(params[:service_ids].split("-"))    
    render layout: "print_report"
  end

  def reconcile_payments
    respond_to do |format|
      format.html do
        @clients = Client.all
        @services = Service.all.where({status: Service.status_reported}).order(start_at: :desc)
      end    

      format.js do
        ba_id = ""
        project_name = ""
        @services = Service.filter_and_order(Service.status_reported, ba_id, params[:client_name], project_name, sort_column, sort_direction)
      end
    end
  end

  def update_service_paid
    unless params[:service_ids].nil?
      params[:service_ids].each do |service_id|
        Service.update_status_to_paid(service_id)
      end
    end
    redirect_to reconcile_payments_reports_path
  end

  def view_calendar
    respond_to do |format|
      format.html {}
      format.json { 
        ba_id = (current_user.has_role?(:admin) || current_user.has_role?(:ismp) || current_user.has_role?(:client) ? params[:assigned_to] : current_user.brand_ambassador.id)
        
        client_name = ""
        if current_user.has_role?(:admin) || current_user.has_role?(:ismp)
          client_name = params[:client_name]
        elsif current_user.has_role?(:client)
          client_name = current_user.client.id
        end
        
        project_name = (current_user.has_role?(:admin) || current_user.has_role?(:ismp) ? params[:project_name] : "")
        render json: Service.calendar_services(params[:status], ba_id, client_name, project_name, sort_column, sort_direction)
      }
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
    @service = Service.find(report_params[:service_id])
    respond_to do |format|
      format.html do
        if @report.save
          @service.update_attribute(:status, Service.status_reported)
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

  def destroy
    msg = nil
    if current_user.has_role?(:admin) || current_user.has_role?(:ismp)
      report = Report.find(params[:id])
      report.destroy
      msg = "Report deleted"
    end
    redirect_to reports_path, {notice: msg}
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
      :products, :product_one, :product_one_beginning, :product_one_end, :product_one_sold, :product_two, 
      :product_two_beginning, :product_two_end, :product_two_sold, :product_three, :product_three_beginning, 
      :product_three_end, :product_three_sold, :product_four, :product_four_beginning, :product_four_end, 
      :product_four_sold, :sample_product, :est_customer_touched, :est_sample_given, :expense_one, :expense_one_img, 
      :expense_two, :expense_two_img, :customer_comments, :ba_comments, :product_one_price, :product_two_price, 
      :product_three_price, :product_four_price, :product_one_sample, :product_two_sample, :product_three_sample, 
      :product_four_sample, :table_image_one_img, :table_image_two_img, :product_five_sample, :product_five_price, 
      :product_five, :product_five_beginning, :product_five_end, :product_five_sold, :product_six_sample, 
      :product_six_price, :product_six, :product_six_beginning, :product_six_end, :product_six_sold, :travel_expense)
  end    

  private
  
  def sort_column
    params[:sort].nil? ? "start_at" : params[:sort]
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end  

  def check_role
    redirect_to(reports_path) if current_user.has_role?(:client)
  end
end