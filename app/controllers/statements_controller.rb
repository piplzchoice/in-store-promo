class StatementsController < ApplicationController
  before_filter :authenticate_user!
  authorize_resource class: StatementsController

  def index
    brand_ambassador = BrandAmbassador.find(params[:brand_ambassador_id])
    @statements = brand_ambassador.statements.all
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
    data = open(statement.file.url)
    send_data(data.read, :filename => statement.file.path.split("/").last, :type => 'application/pdf')        
  end

end
