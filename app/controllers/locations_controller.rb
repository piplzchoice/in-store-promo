class LocationsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_location_status, :only => [:show, :edit, :update]
  
  authorize_resource class: LocationsController

  def index
    respond_to do |format|
      format.html {        
        if session[:filter_history_locations].nil?
          @locations = Location.with_status_active.paginate(:page => params[:page])
        else
          @locations = Location.filter_and_order(session[:filter_history_locations]["is_active"], session[:filter_history_locations]["name"]).paginate(:page => session[:filter_history_locations]["page"])
          @is_active = session[:filter_history_locations]["is_active"]
          @name = session[:filter_history_locations]["name"]
          session[:filter_history_locations] = nil  if request.env["HTTP_REFERER"].nil? || request.env["HTTP_REFERER"].split("/").last == "locations"
        end        
      }
      format.js {
        session[:filter_history_locations] = {"is_active" => params[:is_active], "name" => params[:name], "page" => params[:page]}
        @locations = Location.filter_and_order(session[:filter_history_locations]["is_active"], session[:filter_history_locations]["name"]).paginate(:page => session[:filter_history_locations]["page"])
      }      
    end    
  end

  def new
    @location = Location.new
    respond_to do |format|
      format.html
    end    
  end

  def edit
    @location = Location.find(params[:id])
    respond_to do |format|
      format.html
    end    
  end

  def show
    @location = Location.find(params[:id])
    respond_to do |format|
      format.html
    end    
  end

  def create
    @location = Location.new(location_params)
    @location.user_id = current_user.id
    respond_to do |format|
      format.html do
        if @location.save
          redirect_to locations_url, notice: "Location created"
        else
          render :new
        end
      end
    end       
  end

  def update
    @location = Location.find(params[:id])
    respond_to do |format|
      format.html do
        if @location.update_attributes(location_params)
          redirect_to locations_url, notice: "Location updated"
        else
          render :edit
        end
      end
    end

  end

  def destroy
    @location = Location.find(params[:id])
    msg = ""
    if @location.is_active
      @location.set_data_false
      msg = "Location de-activated"      
    else
      @location.set_data_true
      msg = "Location re-activated"      
    end  

    redirect_to locations_url, {notice: msg}      
  end

  def location_params
    params.require(:location).permit(:name, :address, :city, :state, :zipcode)
  end    

  private

  def check_location_status
    location = Location.find(params[:id])
    redirect_to(locations_path, :flash => { :error => "Location is not active" }) unless location.is_active
  end  
end
