require "csv"
class ReportsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_role, except: [:index, :view_calendar, :show, :download_pdf, :print_pdf]
  helper_method :sort_column, :sort_direction
  authorize_resource class: ReportsController

  def index
    respond_to do |format|
      format.html do
        if current_user.has_role?(:admin) || current_user.has_role?(:ismp) || current_user.has_role?(:coordinator)
          if session[:filter_history_reports].nil?
            @services = Service.all.order(start_at: :desc).paginate(:page => params[:page])
            @status = []
          else
            unless session[:filter_history_reports]["status"].class == Array
              session[:filter_history_reports]["status"] = []
            end
            @services = Service.filter_and_order(session[:filter_history_reports]).paginate(:page => session[:filter_history_reports]["page"])
            @status = session[:filter_history_reports]["status"]
            @assigned_to = session[:filter_history_reports]["assigned_to"]
            @client_name = session[:filter_history_reports]["client_name"]
            @location_name = session[:filter_history_reports]["location_name"]
            @location_fullname = Location.find(@location_name).name unless @location_name == ""
            session[:filter_history_reports] = nil if request.env["HTTP_REFERER"].nil? || request.env["HTTP_REFERER"].split("/").last == "reports"
          end
          set_next_report(@services)
          @brand_ambassadors = BrandAmbassador.with_status_active
          @clients = Client.with_status_active
          @projects = Project.all
          @locations = Location.all
        elsif current_user.has_role?(:client)
          @services = current_user.client.services.where(
            status: Service.client_status_report).order(
            created_at: :desc).paginate(:page => params[:page]
            )

          @brand_ambassadors = @services.collect{|x| x.brand_ambassador }.flatten.uniq
        else
          @services = current_user.brand_ambassador.services.order(created_at: :desc).paginate(:page => params[:page])
        end
      end

      format.js do
        ba_id = (current_user.has_role?(:admin) || current_user.has_role?(:ismp) || current_user.has_role?(:client) || current_user.has_role?(:coordinator) ? params[:assigned_to] : current_user.brand_ambassador.id)

        location_name = ""
        client_name = ""
        is_client = false
        if current_user.has_role?(:admin) || current_user.has_role?(:ismp) || current_user.has_role?(:coordinator)
          client_name = params[:client_name]
          location_name = params[:location_id]
        elsif current_user.has_role?(:client)
          client_name = current_user.client.id
          is_client = true
        end

        session[:filter_history_reports] = {
          "status" => params[:statuses],
          "assigned_to" => ba_id,
          "client_name" => client_name,
          "sort_column" => sort_column,
          "sort_direction" => sort_direction,
          "page" => params[:page],
          "is_client" => is_client,
          "location_name" => location_name
        }

        services = Service.filter_and_order(session[:filter_history_reports])
        set_next_report(services) if current_user.has_role?(:admin) || current_user.has_role?(:ismp) || current_user.has_role?(:coordinator)
        @services = services.paginate(:page => params[:page])
      end

      format.csv do
        ba_id = (current_user.has_role?(:admin) || current_user.has_role?(:ismp) || current_user.has_role?(:client) || current_user.has_role?(:coordinator) ? params[:assigned_to] : current_user.brand_ambassador.id)
        location_name = ""
        client_name = ""
        if current_user.has_role?(:admin) || current_user.has_role?(:ismp) || current_user.has_role?(:coordinator)
          client_name = params[:client_name]
          location_name = params[:location_name]
        elsif current_user.has_role?(:client)
          client_name = current_user.client.id
        end

        data = {
          "status" => params[:statuses].split(","), 
          "assigned_to" => ba_id, 
          "client_name" => client_name, 
          "sort_column" => sort_column, 
          "sort_direction" => sort_direction, 
          "page" => params[:page], 
          "location_name" => location_name,
          "is_client" => false,
        }


        @services = Service.filter_and_order(data)

        headers['Content-Type'] ||= 'text/csv; charset=iso-8859-1;'
        headers['Content-Disposition'] = "attachment; filename=\"report-#{Time.now.to_i}.csv\""
      end
    end
  end

  def ba_payments
    respond_to do |format|
      format.html do
        @filter = false
        @brand_ambassadors = Service.all.where({status: Service.status_paid}).collect{|x| x.brand_ambassador}.uniq
        @services = Service.all.where({status: Service.status_paid}).order(start_at: :desc)
      end

      format.js do
        @filter = true
        @services = Service.filter_and_order({"status" => Service.status_paid, "assigned_to" => params[:assigned_to], "client_name" => "", "sort_column" => sort_column, "sort_direction" => sort_direction})
      end
    end
  end

  def new_ba_payments
    hash_data = BrandAmbassador.process_payments(params[:service_ids])
    hash_data.each_key do |key|
      @ba = BrandAmbassador.find(key)
      @services = @ba.services.find(hash_data[key])
      @totals_ba_paid = Service.calculate_total_ba_paid(hash_data[key])
      @totals_rate = Service.calculate_total_rate(hash_data[key])
      @totals_expense = Service.calculate_total_expense(hash_data[key])
      @totals_travel_expense = Service.calculate_total_travel_expense(hash_data[key])
    end
    respond_to do |format|
      format.html
    end
  end

  def process_ba_payments

    hash_data = BrandAmbassador.process_payments(params[:service_ids])
    hash_data.each_key do |key|

      @line_items = []
      unless params["line-items"].nil?
        params["line-items"].each do |line_item|
          @line_items.push({desc: line_item["desc"], amount: line_item["amount"], reduction: line_item["reduction"]})
        end
      end

      @ba = BrandAmbassador.find(key)
      @services = @ba.services.find(hash_data[key])
      @totals_ba_paid = Service.calculate_total_ba_paid(hash_data[key])
      @totals_rate = Service.calculate_total_rate(hash_data[key])
      @totals_expense = Service.calculate_total_expense(hash_data[key])
      @totals_travel_expense = Service.calculate_total_travel_expense(hash_data[key])
      @grand_total_all = params[:grand_total_all]

      Service.update_to_ba_paid(hash_data[key], current_user.id)

      statement = @ba.statements.build(
        services_ids: hash_data[key],
        line_items: @line_items,
        grand_total: params[:grand_total_all],
        data: Statement.generate_data(hash_data[key])
      )
      statement.save      
      
      PdfGeneratorWorker.perform_async('ba_payment', statement.id)
    end

    redirect_to ba_payments_reports_path
  end

  def print_process_ba_payments
    render layout: "print_report"
  end

  def reconcile_payments
    respond_to do |format|
      format.html do
        @services = Service.all.where({status: Service.status_reported}).order(start_at: :desc)
        @clients = @services.collect{|x| x.client}.uniq
      end

      format.js do
        ba_id = ""
        @services = Service.filter_and_order({"status" => Service.status_reported, "assigned_to" => ba_id, "client_name" => params[:client_name], "sort_column" => sort_column, "sort_direction" => sort_direction})
      end
    end
  end

  def update_service_paid
    unless params[:service_ids].nil?
      params[:service_ids].each do |service_id|
        Service.update_status_to_paid(service_id, current_user.id)
      end
    end
    redirect_to reconcile_payments_reports_path
  end

  def view_calendar
    respond_to do |format|
      format.html {}
      format.json {
        ba_id = (current_user.has_role?(:admin) || current_user.has_role?(:ismp) || current_user.has_role?(:client) || current_user.has_role?(:coordinator) ? params[:assigned_to] : current_user.brand_ambassador.id)

        client_name = ""
        is_client = false
        if current_user.has_role?(:admin) || current_user.has_role?(:ismp) || current_user.has_role?(:coordinator)
          client_name = params[:client_name]
        elsif current_user.has_role?(:client)
          client_name = current_user.client.id
          is_client = true
        end

        render json: Service.calendar_services(params, ba_id, client_name, sort_column, sort_direction, is_client)
      }
    end
  end

  def show
    @next_report = false

    unless session[:next_report].nil?
      idx = session[:next_report].index(params[:id].to_i)
      size = session[:next_report].size

       unless idx.nil?
        unless size == (idx + 1)
          @next_report = true
          @next_data = Report.find(session[:next_report][idx.to_i + 1])
        end
      end
    end

    @report = Report.find(params[:id])
    @service = @report.service
  end

  def new
    @service = Service.find(params[:service_id])

    if @service.is_co_op? && !@service.parent.nil?
      redirect_to new_report_url(service_id: @service.parent.id)
    else
      @report = @service.build_report
    end

  end

  def create
    @report = Report.new_data(report_params)
    @service = Service.find(report_params[:service_id])
    image_table = params["image-table"]
    image_expense = params["image-expense"]
    respond_to do |format|
      format.html do

        if @service.is_co_op?
          @report_coop = Report.new_coop_data(report_params, @service.co_op_services.first.id)

          if @report.save && @report_coop.save

            @service.update_status(Service.status_reported, current_user.id)
            @service.co_op_services.first.update_status(Service.status_reported, current_user.id)

            save_report_data(@report, image_table, image_expense)
            save_coop_report_data(@report_coop, image_table, image_expense)
          else
            render :new
          end
        else
          if @report.save
            @service.update_status(Service.status_reported, current_user.id)
            save_report_data(@report, image_table, image_expense)
          else
            render :new
          end
        end

        redirect_to report_path(@report), notice: "Report created"
      end
    end
  end

  def edit
    @report = Report.find(params[:id])
    @service = @report.service

    if @report.is_old_report
      if @service.is_co_op? && !@service.parent.nil?
        redirect_to edit_report_url(@report)
      end
    end
  end

  def update
    @report = Report.find(params[:id])
    @service = @report.service
    respond_to do |format|
      format.html do
        if @report.update_attributes(report_params)

           unless params["image-table"].nil?
             if params["image-table"].class == String
               image = ReportTableImage.find(params["image-table"])
               image.report = @report
               image.save
             else
               params["image-table"].each do |id_table|
                 image = ReportTableImage.find(id_table)
                 image.report = @report
                 image.save
               end
             end
           end

           unless params["image-expense"].nil?
             if params["image-expense"].class == String
               image = ReportExpenseImage.find(params["image-expense"])
               image.report = @report
               image.save
             else
               params["image-expense"].each do |id_expense|
                 image = ReportExpenseImage.find(id_expense)
                 image.report = @report
                 image.save
               end
             end
           end

          PdfGeneratorWorker.perform_async('report', @report.id, true)

          redirect_to report_path(@report), notice: "Report updated"
        else
          render :edit
        end
      end
    end
  end

  def destroy
    msg = nil
    if current_user.has_role?(:admin) || current_user.has_role?(:ismp) || current_user.has_role?(:coordinator)
      report = Report.find(params[:id])
      service = report.service

      if service.is_co_op? && !report.is_old_report
        if !service.parent.nil?
        else
        end
      end

      report.destroy
      msg = "Report deleted"
    end
    redirect_to reports_path, {notice: msg}
  end

  def download_pdf
    report = Report.find(params[:id])

    if report.file_pdf.blank?
      redirect_to report_path(report), {notice: "System still generate pdf for this report, please try again in a few minutes"}
    else
      if Rails.env.eql?("development")
        send_file(Rails.root.to_s + "/public" + report.file_pdf.url, 
          {:filename => report.file_pdf.url.split("/").last, :type => 'application/pdf'})
      else
        data = open(report.file_pdf.url)
        send_file(data, :filename => report.file_pdf.url.split("/").last, :type => 'application/pdf')
      end
    end

  end

  def print_pdf
    @report = Report.find(params[:id])
    @service = @report.service
  end

  def export_data
    # @services = Service.where(status: [6])
    # @services = Report.all.collect{|x| x.service}.compact.sort{|x, y| y.report.id <=> x.report.id}
  end

  def generate_export_data
    send_file(Report.generate_export_data, {:content_type => "application/vnd.ms-excel", :disposition => 'inline'})
  end

  def upload_image
    responses = {}
    responses["files"] = []

    if params[:key] == "table"
      params[:files].each do |file|
        image = ReportTableImage.new
        image.file = file
        image.save
        responses["files"] << {id: image.id, url: image.file.url, key: params[:key]}
      end
    elsif params[:key] == "expense"
      params[:files].each do |file|
        image = ReportExpenseImage.new
        image.file = file
        image.save
        responses["files"] << {id: image.id, url: image.file.url, key: params[:key]}
      end
    end

    render json: responses
  end

  def delete_image

    if params[:key] == "table"
      image = ReportTableImage.find(params[:id])
      image.destroy
    elsif params[:key] == "expense"
      image = ReportExpenseImage.find(params[:id])
      image.destroy
    end

    render json: {res: true}
  end

  def report_params
    params.require(:report).permit(:service_id,
      :demo_in_store, :weather, :traffic, :busiest_hours,
      :products, :product_one, :product_one_beginning,
      :product_one_end, :product_one_sold, :product_two,
      :product_two_beginning, :product_two_end, :product_two_sold,
      :product_three, :product_three_beginning,
      :product_three_end, :product_three_sold, :product_four,
      :product_four_beginning, :product_four_end,
      :product_four_sold, :sample_product, :est_customer_touched,
      :est_sample_given, :expense_one, :expense_one_img,
      :expense_two, :expense_two_img, :customer_comments,
      :ba_comments, :product_one_price, :product_two_price,
      :product_three_price, :product_four_price, :product_one_sample,
      :product_two_sample, :product_three_sample,
      :product_four_sample, :table_image_one_img, :table_image_two_img,
      :product_five_sample, :product_five_price, :product_five,
      :product_five_beginning, :product_five_end, :product_five_sold,
      :product_six_sample, :product_six_price, :product_six,
      :product_six_beginning, :product_six_end, :product_six_sold, :travel_expense,
      :hide_client_name, :hide_client_product, :hide_client_coop_name, :hide_client_coop_product,
      :client_products => [:name, :price, :sample, :beginning, :end, :sold, :id],
      :client_coop_products => [:name, :price, :sample, :beginning, :end, :sold, :id])
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

  def save_report_data(report_data, image_table, image_expense)
    unless image_table.nil?
      image_table.each do |id_table|
        image = ReportTableImage.find(id_table)
        image.report = report_data
        image.save
      end
    end

    unless image_expense.nil?
      image_expense.each do |id_expense|
        image = ReportExpenseImage.find(id_expense)
        image.report = report_data
        image.save
      end
    end

    report_data.save
    generate_pdf_report(report_data.id)
  end

  def save_coop_report_data(report_data, image_table, image_expense)
    unless image_table.nil?
      image_table.each do |id_table|
        img = ReportTableImage.find(id_table)
        image = img.dup
        image.report = report_data

        if Rails.env == "development"
          File.open(img.file.path){|f| image.file = f}
        else
          image.remote_file_url = img.file.url
        end

        image.save
      end
    end

    unless image_expense.nil?
      image_expense.each do |id_expense|
        img = ReportExpenseImage.find(id_expense)
        image = img.dup
        image.report = report_data

        if Rails.env == "development"
          File.open(img.file.path){|f| image.file = f}
        else
          image.remote_file_url = img.file.url
        end

        image.save
      end
    end

    report_data.save
    
    generate_pdf_report(report_data.id)
  end

  private

  def set_next_report(services)
    session[:next_report] = services.collect do |service|
      if service.is_reported?
        service.report.id unless service.report.nil?
      end
    end.compact
  end

  def generate_pdf_report(report_id)
    PdfGeneratorWorker.perform_async('report', report_id)
  end

end
