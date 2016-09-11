class AssignmentsController < ApplicationController
  before_filter :authenticate_user!
  authorize_resource class: AssignmentsController

  def index
    respond_to do |format|
      format.html {
        @statements = current_user.brand_ambassador.statements.order(created_at: :desc)
      }
      format.json {
        render json: current_user.brand_ambassador.available_calendar
      }
    end
  end

  def show
    @service = current_user.brand_ambassador.services.find(params[:id])
  end

  def comment
    service = Service.find(params[:id])
    Log.record_comment_of_inventory(service.id, params[:comments], current_user.id)
    redirect_to assignment_path({id: params[:id]}) and return    
  end

end
