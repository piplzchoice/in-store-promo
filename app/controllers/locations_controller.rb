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
        @location_ids = (params[:location_ids] == "" ? nil : params[:location_ids].split(",")) 
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

  def export_data
    unless params[:loc_ids] == ""
      @locations = Location.find(params[:loc_ids].split(","))

      book = Spreadsheet::Workbook.new
      sheet1 = book.create_worksheet :name => 'Data'
      sheet1.row(0).replace [
        "Location Name",
        "Address",
        "City",
        "State",
        "Zipcode",
        "Contact Name",
        "Phone",
        "Email",
        "Notes"
      ]

      @locations.each_with_index do |location, i|
        sheet1.row(i + 1).replace location.export_data
      end

      export_file_path = [Rails.root, "tmp", "export-location-data-#{Time.now.to_i}.xls"].join("/")
      book.write export_file_path
      send_file export_file_path, :content_type => "application/vnd.ms-excel", :disposition => 'inline'
    else 
      redirect_to locations_url, {notice: "Please select location to export"}
    end
  end

  def location_params
    params.require(:location).permit(:name, :address, :city, :state, :zipcode, :contact, :phone, :email ,:notes)
  end    

  private

  def check_location_status
    location = Location.find(params[:id])
    redirect_to(locations_path, :flash => { :error => "Location is not active" }) unless location.is_active
  end  
end
