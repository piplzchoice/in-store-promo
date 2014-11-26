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
    @client = Client.find(params[:client_id])
    @services = @client.services.find(params[:service_ids])
    invoice = Invoice.new_data(params[:client_id], params[:service_ids], line_items)

    if invoice.save
      redirect_to invoices_path
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

end
