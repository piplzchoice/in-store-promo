class AssignmentsController < ApplicationController
  before_filter :authenticate_user!
  authorize_resource class: AssignmentsController      

  def index
    respond_to do |format|
      format.html
      format.json { render json: current_user.brand_ambassador.get_assignments}
    end        
  end

  def show
    @service = current_user.brand_ambassador.services.find(params[:id])
  end

end
