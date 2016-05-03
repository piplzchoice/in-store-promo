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

end
