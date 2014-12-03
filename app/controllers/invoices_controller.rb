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
        @invoices = Invoice.all.where({status: 0}).order(created_at: :desc)
        @clients = @invoices.collect{|x|x.client}.uniq
      end    

      format.js do
        @invoices = Invoice.filter_and_order({
          "client_name" => params[:client_name], 
          "status" => 0,
          "sort_column" => sort_column, 
          "sort_direction" => sort_direction}
        )
      end
    end
  end

  def paid
    @paid = true
    respond_to do |format|
      format.html do
        @invoices = Invoice.all.where({status: 1}).order(created_at: :desc)
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

  def update
    @invoice = Invoice.find(params[:id])
    @invoice.service_ids.split(",").each do |service_id|
      Service.update_status_to_paid(service_id)
    end     
    @invoice.update_data(invoice_params.merge(status: 1))
    # @invoice.update_attribute(:status, 1)
    # redirect_to invoices_path
    redirect_to list_invoices_path
  end

  def show
    @invoice = Invoice.find(params[:id])
    @client = @invoice.client
    @services = Service.find(@invoice.service_ids.split(","))
  end

  def new
    @client = Client.find(params[:client_id])
    @services = @client.services.find(params[:service_ids])
    @service_ids = params[:service_ids]
  end

  def create
    line_items = []
    unless params["line-items"].nil?
      params["line-items"].each do |line_item|
        line_items.push({desc: line_item["desc"], amount: line_item["amount"]})
      end      
    end

    # @client = Client.find(params[:client_id])
    # @services = @client.services.find(params[:service_ids])
    invoice = Invoice.new_data(
      params[:client_id], params[:service_ids], line_items, 
      params[:rate_total_all], params[:expsense_total_all], 
      params[:travel_total_all], params[:grand_total_all], 
      params[:grand_total])

    if invoice.save
      params[:service_ids].split(",").each do |service_id|
        Service.update_status_to_invoiced(service_id)
      end      
      redirect_to list_invoices_path
    else
      render :new
    end    
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
