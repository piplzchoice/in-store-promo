class MyStatementsController < ApplicationController
  before_filter :authenticate_user!
  # authorize_resource class: MyStatementsController

  def index
    respond_to do |format|
      format.html do
        @statements = current_user.brand_ambassador.statements.paginate(:page => 1)
      end
      format.js do
        @statements = current_user.brand_ambassador.statements.paginate(:page => params[:page])
      end
    end
  end

  def show
    @brand_ambassador = current_user.brand_ambassador
    @statement = current_user.brand_ambassador.statements.find(params[:id])
    @services = current_user.brand_ambassador.services.find(@statement.services_ids)
    @totals_ba_paid = current_user.brand_ambassador.services.calculate_total_ba_paid(@statement.services_ids)
  end

  def download
    brand_ambassador = current_user.brand_ambassador
    statement = brand_ambassador.statements.find(params[:id])
    send_data(File.read(statement.file.path), :filename => statement.file.path.split("/").last, :type => 'application/pdf')
  end

end
