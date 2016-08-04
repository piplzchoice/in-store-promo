class LocationsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_location_status, :only => [:show, :edit, :update]
  helper_method :sort_column, :sort_direction
  authorize_resource class: LocationsController

  def index
    respond_to do |format|
      format.html {
        if session[:filter_history_locations].nil?
          @locations = Location.with_status_active.paginate(:page => params[:page])
          @loc_id = Location.with_status_active.select(:id).collect(&:id).join(",")
        else
          locations = Location.filter_and_order(session[:filter_history_locations])
          @locations = locations.paginate(:page => session[:filter_history_locations]["page"])
          @loc_id = locations.collect(&:id).join(",")
          @is_active = session[:filter_history_locations]["is_active"]
          @location_name = session[:filter_history_locations]["location_name"]
          @city = session[:filter_history_locations]["city"]

          unless @location_name == ""
            if @location_name.to_i != 0
              @location_fullname = Location.find(@location_name).name
            else
              @location_fullname = @location_name
            end
          end

          session[:filter_history_locations] = nil  if request.env["HTTP_REFERER"].nil? || request.env["HTTP_REFERER"].split("/").last == "locations"
        end
      }
      format.js {
        @location_ids = (params[:location_ids] == "" ? nil : params[:location_ids].split(","))

        session[:filter_history_locations] = {
          "is_active" => params[:is_active],
          "location_name" => (params[:location_id] == "" ? "" : params[:location_name]),
          "city" => params[:city],
          "sort_column" => sort_column,
          "sort_direction" => sort_direction,
          "page" => params[:page],
        }

        locations = Location.filter_and_order(session[:filter_history_locations])
        @locations = locations.paginate(:page => session[:filter_history_locations]["page"])
        @loc_id = locations.collect(&:id).join(",")
      }
    end
  end

  def new
    @location = Location.new
    @territories = Territory.all
    respond_to do |format|
      format.html
    end
  end

  def edit
    @location = Location.find(params[:id])
    @territories = Territory.all
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
          @territories = Territory.all
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
          @territories = Territory.all
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

  def deactive_data
    unless params[:loc_ids] == ""
      @locations = Location.where(id: params[:loc_deactive_ids].split(","))

      @locations.each_with_index do |location, i|
        location.set_data_false
      end

      redirect_to locations_url, {notice: "Success Deactive Locations"}
    else
      redirect_to locations_url, {notice: "Please select location to deactive"}
    end
  end

  def export_data
    unless params[:loc_ids] == ""
      @locations = Location.where(id: params[:loc_ids].split(","), is_active: params[:loc_status])
      total_ba = Location.all.collect{|x| x.brand_ambassadors.with_status_active.size}.max

      fields = [
        "Location Name",
        "Address",
        "City",
        "Zipcode",
        "Contact Name",
        "Phone",
        "Email",
        "Notes"
      ]

      unless total_ba.blank?
        total_ba.times.each do |itr|
          fields << "BA #{itr + 1}"
        end
      end

      book = Spreadsheet::Workbook.new
      sheet1 = book.create_worksheet :name => 'Data'
      sheet1.row(0).replace fields

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

  def autocomplete_name
    locations = Location.autocomplete_search(params[:q]).to_a
    o = Location.new({id: "987654321", name: "Keywords '#{params[:q]}'", city: params[:q]})
    locations.insert(0, o)
    respond_to do |format|
      format.json do
        render json: locations
      end
    end
  end

  def import_data
    status = Location.import_location_excel(params[:file])
    redirect_to locations_url, notice: status
  end


  private

  def location_params
    params.require(:location).permit(:name, :address, :city, :state, :zipcode, :contact, :phone, :email ,:notes, :territory_id)
  end

  def check_location_status
    location = Location.find(params[:id])
    redirect_to(locations_path, :flash => { :error => "Location is not active" }) unless location.is_active
  end

  def sort_column
    params[:sort].nil? ? "name" : params[:sort]
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end
end
