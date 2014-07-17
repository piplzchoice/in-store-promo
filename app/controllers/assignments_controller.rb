class AssignmentsController < ApplicationController
  before_filter :authenticate_user!
  authorize_resource class: AssignmentsController 

  def index
  end

  def show
    @service = current_user.brand_ambassador.services.find(params[:id])
    render layout: false
  end

  def new_report
    @service = current_user.brand_ambassador.services.find(params[:id])
  end

  def create_report
    @service = current_user.brand_ambassador.services.find(params[:id])
  end  

  def download_pdf
    file = "report-#{Time.now.to_i}.pdf"

    @service = Service.find(params[:id])
    html = render_to_string(:layout => "print_report", :action => "print_pdf", :id => params[:id])
    kit = PDFKit.new(html)
    kit.stylesheets << "#{Rails.root}/app/assets/stylesheets/application.css.scss"
    send_data(kit.to_pdf, :filename => file, :type => 'application/pdf')    
  end

  def print_pdf
    @service = Service.find(params[:id])
  end
end
