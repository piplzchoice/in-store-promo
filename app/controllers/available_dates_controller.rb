class AvailableDatesController < ApplicationController
  before_filter :authenticate_user!
  authorize_resource class: AvailableDatesController    

  def index
    respond_to do |format|
      format.html
      format.json { render json: current_user.brand_ambassador.available_calendar }
    end       
  end

  def manage
    @available_date = AvailableDate.new
    respond_to do |format|
      format.html
      format.js {
        @date = {year: params["ba"]["date(1i)"], month: params["ba"]["date(2i)"]}
        @montly_date = current_user.brand_ambassador.get_monthly_date(@date)
      }
    end       
  end

  def update_date
    @available_date = AvailableDate.new_data(params[:dates], current_user.brand_ambassador)    
    respond_to do |format|
      format.html do
        # if @available_date.save
          redirect_to assignments_url          
        # else
          # render :new
        # end
      end      
    end
  end

  # def show
  #   assign_available_date
  # end

  # def destroy
  #   assign_available_date
  #   if @available_date.destroy
  #     redirect_to available_dates_url, {notice: "Date deleted"}
  #   end        
  # end

  def available_date_params
    params.require(:available_date).permit(:availablty, :am, :pm)
  end    

  # def assign_available_date
  #   @available_date = AvailableDate.find(params[:id])
  #   redirect_to(available_dates_url, :flash => { :error => "Not your available date" }) unless @available_date.brand_ambassador_id == current_user.brand_ambassador.id
  # end

end
