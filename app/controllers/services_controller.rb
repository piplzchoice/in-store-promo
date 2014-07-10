class ServicesController < ApplicationController
  before_filter :authenticate_user!
  
  authorize_resource class: ServicesController

  def index
    render json: Project.calendar_services(params[:project_id])
  end

  def new
    @project = Project.find(params[:project_id])
    @service = @project.services.build
    respond_to do |format|
      format.html
    end    
  end

  def create
    @project = Project.find(params[:project_id])
    @service = @project.services.build_data(service_params)
    respond_to do |format|
      format.html do
        if @service.save
          redirect_to project_path(@project), notice: "Service created"
        else
          render :new
        end
      end
    end    
  end

  def edit
    @project = Project.find(params[:project_id])
    @service = @project.services.find(params[:id])
    respond_to do |format|
      format.html
    end        
  end

  def update
    @project = Project.find(params[:project_id])
    @service = @project.services.find(params[:id])
    respond_to do |format|
      format.html do
        if @service.update_data(service_params)
          redirect_to project_service_path({project_id: params[:project_id], id: params[:id]}), notice: "Service Updated"
        else
          render :edit
        end
      end
    end        
  end

  def show
    @project = Project.find(params[:project_id])
    @service = @project.services.find(params[:id])    
  end

  def destroy
    @project = Project.find(params[:project_id])
    @service = @project.services.find(params[:id])    
    if @service.destroy
      redirect_to project_path(@project), {notice: "Service deleted"}
    end            
  end

  def autocomplete_location_name
    respond_to do |format|
      format.json do
        render json: Location.autocomplete_search(params[:q])
      end
    end        
  end

  def generate_select_ba
    @brand_ambassadors = BrandAmbassador.get_available_people(params[:start_at])
    @brand_ambassadors.push BrandAmbassador.find params[:ba_id] if params[:action_method] == "edit" || params[:action_method] == "update"

    render layout: false    
  end

  def service_params
    params.require(:service).permit(:location_id, :brand_ambassador_id, :start_at, :end_at, :details)
  end

end

  # "service"=>{"location_id"=>"3", "brand_ambassador_id"=>"6", 
  #   "start_at"=>"10/10/2013 9:00 AM", "end_at"=>"07/08/2014 10:00 PM", "details"=>""}

