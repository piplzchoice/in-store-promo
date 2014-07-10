class AvailableDatesController < ApplicationController
  before_filter :authenticate_user!
  authorize_resource class: AvailableDatesController    

  def index
    respond_to do |format|
      format.html
      format.json { render json: current_user.brand_ambassador.available_calendar }
    end       
  end

  def new
    @available_date = AvailableDate.new
    @disable_dates = current_user.brand_ambassador.disable_dates
    respond_to do |format|
      format.html
    end       
  end

  def create
    @available_date = AvailableDate.new_data(available_date_params)
    @available_date.brand_ambassador_id = current_user.brand_ambassador.id
    respond_to do |format|
      format.html do
        if @available_date.save
          redirect_to available_dates_url, notice: "Date created"
        else
          render :new
        end
      end      
    end
  end

  def show
    assign_available_date
  end

  def destroy
    assign_available_date
    if @available_date.destroy
      redirect_to available_dates_url, {notice: "Date deleted"}
    end        
  end

  def available_date_params
    params.require(:available_date).permit(:availablty)
  end    

  def assign_available_date
    @available_date = AvailableDate.find(params[:id])
    redirect_to(available_dates_url, :flash => { :error => "Not your available date" }) unless @available_date.brand_ambassador_id == current_user.brand_ambassador.id
  end

end
