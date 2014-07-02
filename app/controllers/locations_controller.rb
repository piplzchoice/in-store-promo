class LocationsController < ApplicationController
  before_filter :authenticate_user!
  
  authorize_resource class: LocationsController

  def index
    @locations = Location.all
    respond_to do |format|
      format.html
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
    if @location.destroy
      redirect_to locations_url, {notice: "Location deleted"}
    end    
  end

  def location_params
    params.require(:location).permit(:name, :address, :city, :state, :zipcode)
  end    
end
