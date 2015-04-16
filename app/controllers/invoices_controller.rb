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

  def update
    @invoice = Invoice.find(params[:id])
    @invoice.service_ids.split(",").each do |service_id|
      Service.update_status_to_paid(service_id)
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
    @services = Service.find(@invoice.service_ids.split(","))
  end

  def new
    @client = Client.find(params[:client_id])
    @services = @client.services.find(params[:service_ids])
    @service_ids = params[:service_ids]
    @invoice_number = "INV-%05d" % ((Invoice.all.size == 0 ? 0 : Invoice.last.id) + 1)
  end

  def create
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
        Service.update_status_to_invoiced(service_id)
      end      
  
      @client = @invoice.client
      @services = Service.find(@invoice.service_ids.split(","))
      file = "invoice-#{Time.now.to_i}.pdf"
      html = render_to_string(:layout => "print_invoice", :action => "print", :id => @invoice.id)
      kit = PDFKit.new(html)
      kit.stylesheets << "#{Rails.root}/app/assets/stylesheets/application.css.scss"
      @invoice.update_attribute(:file, kit.to_file("#{Rails.root}/tmp/#{file}"))
      @client.update_attribute(:additional_emails, params[:list_emails].split(";"))
      ApplicationMailer.send_invoice(@invoice, params[:list_emails]).deliver
      redirect_to list_invoices_path
    else
      render :new
    end    
  end

  def download
    file = "invoice-#{Time.now.to_i}.pdf"

    @invoice = Invoice.find(params[:id])
    @client = @invoice.client
    @services = Service.find(@invoice.service_ids.split(","))

    html = render_to_string(:layout => "print_invoice", :action => "print", :id => params[:id])
    kit = PDFKit.new(html)
    kit.stylesheets << "#{Rails.root}/app/assets/stylesheets/application.css.scss"
    send_data(kit.to_pdf, :filename => file, :type => 'application/pdf')    
  end

  def print
    @invoice = Invoice.find(params[:id])
    @client = @invoice.client
    @services = Service.find(@invoice.service_ids.split(","))
    render layout: "print_invoice"
  end 

  def resend
    @invoice = Invoice.find(params[:id])
    ApplicationMailer.send_invoice(@invoice, @invoice.list_email).deliver
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
