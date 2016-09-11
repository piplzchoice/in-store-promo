class InvoicesController < ApplicationController
  before_filter :authenticate_user!
  helper_method :sort_column, :sort_direction
  authorize_resource class: InvoicesController 

  def index
    @filter = false
    respond_to do |format|
      format.html do
        @services = Service.all.where({status: Service.status_reported}).order(start_at: :desc)        
        @clients = @services.collect{|x|x.client}.uniq
      end    

      format.js do
        @client_id = params[:client_name]
        @filter = true if params[:client_name] != ""
        @services = Service.filter_and_order({
          "status" => Service.status_reported, 
          "assigned_to" => "", 
          "client_name" => params[:client_name], 
          "sort_column" => sort_column, 
          "sort_direction" => sort_direction}
        )
      end
    end
  end

  def list
    @paid = false
    respond_to do |format|
        format.html do
          @invoices = Invoice.all.where({status: 0}).order(issue_date: :asc)
          @clients = @invoices.collect{|x|x.client}.uniq
          
          unless session[:filter_history_invoice].nil?
            @invoices = Invoice.filter_and_order(session[:filter_history_invoice])
            @client_name = session[:filter_history_invoice]["client_name"]
          end              
      end    

      format.js do

        session[:filter_history_invoice] = {
          "client_name" => params[:client_name], 
          "status" => 0,
          "sort_column" => sort_column, 
          "sort_direction" => sort_direction
        }

        @invoices = Invoice.filter_and_order(session[:filter_history_invoice])
      end
    end
  end

  def paid
    @paid = true
    respond_to do |format|
      format.html do
        @invoices = Invoice.all.where({status: 1}).order(issue_date: :desc)
        @clients = @invoices.collect{|x|x.client}.uniq
      end    

      format.js do
        @invoices = Invoice.filter_and_order({
          "client_name" => params[:client_name], 
          "status" => 1,
          "sort_column" => sort_column, 
          "sort_direction" => sort_direction}
        )
      end
    end
  end

  def update_paid
    @invoice = Invoice.find(params[:id])
    @invoice.service_ids.split(",").each do |service_id|
      Service.update_status_to_paid(service_id, current_user.id)
    end     
    @invoice.update_data(invoice_params.merge(status: 1))
    # @invoice.update_attribute(:status, 1)
    # redirect_to invoices_path

    ApplicationMailer.thank_you_for_payment(@invoice).deliver
    redirect_to list_invoices_path
  end

  def show
    @invoice = Invoice.find(params[:id])
    @client = @invoice.client
    # @services = Service.find(@invoice.service_ids.split(","))
  end

  def new
    @client = Client.find(params[:client_id])
    @services = @client.services.find(params[:service_ids])
    @service_ids = params[:service_ids]
    @invoice_number = "INV-%05d" % ((Invoice.all.size == 0 ? 0 : Invoice.last.id) + 1)
  end

  def create
    is_exist = false
    exist_service_ids = Invoice.all.collect(&:service_ids).join(",").split(",")
    params[:service_ids].split(",").each do |service_id|
      is_exist = exist_service_ids.include?(service_id)
      break if is_exist
    end      

    if !is_exist

      line_items = []
      unless params["line-items"].nil?
        params["line-items"].each do |line_item|
          line_items.push({desc: line_item["desc"], amount: line_item["amount"], reduction: line_item["reduction"]})
        end      
      end

      @client = Client.find(params[:client_id])
      @services = @client.services.find(params[:service_ids])
      @invoice = Invoice.new_data(
        params[:client_id], params[:service_ids], line_items, 
        params[:rate_total_all], params[:expsense_total_all], 
        params[:travel_total_all], params[:grand_total_all], 
        params[:grand_total], params[:invoice])
      
      if @invoice.save
        params[:service_ids].split(",").each do |service_id|
          Service.update_status_to_invoiced(service_id, current_user.id)
        end      
    
        @client = @invoice.client
        @client.update_attribute(:additional_emails, params[:list_emails].split(";"))
        PdfGeneratorWorker.perform_async('invoice', @invoice.id)
        redirect_to list_invoices_path
      else
        render :new
      end    
    else
      redirect_to invoices_path
    end
  end

  def edit
    @invoice = Invoice.find(params[:id])
    @client = @invoice.client
    @services = Service.find(@invoice.service_ids.split(","))
  end

  def update
    line_items = []
    unless params["line-items"].nil?
      params["line-items"].each do |line_item|
        line_items.push({desc: line_item["desc"], amount: line_item["amount"], reduction: line_item["reduction"]})
      end      
    end

    @invoice = Invoice.find(params[:id])
    @client = @invoice.client
    @services = Service.find(@invoice.service_ids.split(","))

    if @invoice.update_invoice(line_items, params[:rate_total_all], params[:expsense_total_all], params[:travel_total_all], params[:grand_total_all], params[:grand_total])
      @client.update_attribute(:additional_emails, params[:list_emails].split(";"))
      PdfGeneratorWorker.perform_async('invoice', @invoice.id)
      redirect_to list_invoices_path
    else
      render :edit
    end        
  end

  def download
    invoice = Invoice.find(params[:id])

    if invoice.file.blank?
      redirect_to customer_report_path({id: invoice.uuid}), notice: "PDF is still generating, please try again in few minutes"
    else
      if Rails.env.eql?("development")
        send_file(Rails.root.to_s + "/public" + invoice.file.url, :filename => invoice.file.url.split("/").last, :type => 'application/pdf')
      else
        data = open(invoice.file.url)
        send_file(data, :filename => invoice.file.url.split("/").last, :type => 'application/pdf')
      end      
    end    
  end 

  def resend
    @invoice = Invoice.find(params[:id])

    ApplicationMailer.send_invoice(@invoice.id).deliver
    redirect_to invoice_path(@invoice), notice: "Invoice sent"
  end

  private
  
  def sort_column
    params[:sort].nil? ? "start_at" : params[:sort]
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end  

  def invoice_params
    params.require(:invoice).permit(:amount_received, :date_received)
  end    

end
