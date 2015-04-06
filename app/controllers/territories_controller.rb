class TerritoriesController < ApplicationController
  before_filter :authenticate_user!
  authorize_resource class: TerritoriesController  

  def index
    respond_to do |format|
      format.html {        
        # if session[:filter_history_locations].nil?
          @territories = Territory.paginate(:page => params[:page])
        # else
        #   @locations = Territory.filter_and_order(session[:filter_history_locations]["is_active"], session[:filter_history_locations]["name"]).paginate(:page => session[:filter_history_locations]["page"])
        #   @is_active = session[:filter_history_locations]["is_active"]
        #   @name = session[:filter_history_locations]["name"]
        #   session[:filter_history_locations] = nil  if request.env["HTTP_REFERER"].nil? || request.env["HTTP_REFERER"].split("/").last == "locations"
        # end        
      }
      format.js {
        @location_ids = (params[:location_ids] == "" ? nil : params[:location_ids].split(",")) 
        session[:filter_history_locations] = {"is_active" => params[:is_active], "name" => params[:name], "page" => params[:page]}
        @locations = Territory.filter_and_order(session[:filter_history_locations]["is_active"], session[:filter_history_locations]["name"]).paginate(:page => session[:filter_history_locations]["page"])
      }      
    end    
  end

  def new
    @territory = Territory.new
    respond_to do |format|
      format.html
    end    
  end

  def edit
    @territory = Territory.find(params[:id])
    respond_to do |format|
      format.html
    end    
  end

  def show
    @territory = Territory.find(params[:id])
    respond_to do |format|
      format.html
    end    
  end

  def create
    @territory = Territory.new(territory_params)
    respond_to do |format|
      format.html do
        if @territory.save
          redirect_to territories_url, notice: "Territory created"
        else
          render :new
        end
      end
    end       
  end

  def update
    @territory = Territory.find(params[:id])
    respond_to do |format|
      format.html do
        if @territory.update_attributes(territory_params)
          redirect_to territories_url, notice: "Territory updated"
        else
          render :edit
        end
      end
    end

  end

  def destroy
    # @territory = Territory.find(params[:id])
    # msg = ""
    # it @territory.is_active
    #   @location.set_data_false
    #   msg = "Territory de-activated"      
    # else
    #   @location.set_data_true
    #   msg = "Territory re-activated"      
    # end  

    redirect_to territories_url, {notice: msg}      
  end


  def territory_params
    params.require(:territory).permit(:name)
  end    

  private

  # def check_location_status
  #   location = Territory.find(params[:id])
  #   redirect_to(locations_path, :flash => { :error => "Territory is not active" }) unless location.is_active
  # end    
end
