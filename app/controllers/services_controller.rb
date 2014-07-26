class ServicesController < ApplicationController
  before_filter :authenticate_user!, except: [:confirm_respond, :rejected_respond]
  
  authorize_resource class: ServicesController, except: [:confirm_respond, :rejected_respond]

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
          ApplicationMailer.ba_assignment_notification(@service.brand_ambassador, @service).deliver          
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
    # is_ba_changed = @service.changed_attributes["brand_ambassador_id"].nil?    
    respond_to do |format|
      format.html do
        if @service.can_modify?
          if @service.update_data(service_params)
            redirect_to project_service_path({project_id: params[:project_id], id: params[:id]}), notice: "Service Updated"
          end          
        end
        render :edit
      end
    end        
  end

  def show
    @project = Project.find(params[:project_id])
    @service = @project.services.find(params[:id])
  end

  def update_status_after_reported
    @project = Project.find(params[:project_id])
    @service = @project.services.find(params[:id])    
    @service.update_attributes({status: params[:service_status]})
    redirect_to project_service_path(project_id: @project.id, id: @service.id)
  end

  def destroy
    @project = Project.find(params[:project_id])
    @service = @project.services.find(params[:id])    
    if @service.cancelled
      ApplicationMailer.cancel_assignment_notification(@service.brand_ambassador, @service).deliver
      redirect_to project_path(@project), {notice: "Service Cancelled"}
    else
      render :show
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

  def confirm_respond
    @project = Project.find(params[:project_id])
    unless @project.nil?
      @service = @project.services.find(params[:id])    
      unless @service.nil?
        if Devise.secure_compare(@service.token, params[:token])
          @service.update_attributes({status: Service.status_confirmed, token: Devise.friendly_token})          
          ApplicationMailer.send_ics(@service.brand_ambassador, @service).deliver
        end
      end
    end
    
    redirect_to root_path
  end

  def rejected_respond
    @project = Project.find(params[:project_id])
    unless @project.nil?
      @service = @project.services.find(params[:id])    
      unless @service.nil?
        if Devise.secure_compare(@service.token, params[:token])
          @service.update_attributes({status: Service.status_rejected, token: Devise.friendly_token})
        end
      end
    end
    
    redirect_to root_path    
  end

  def mark_service_as_complete
    msg = "Service update failed"
    @project = Project.find(params[:project_id])
    unless @project.nil?
      @service = @project.services.find(params[:id])    
      unless @service.nil?
        @service.update_attributes({status: Service.status_conducted})
        msg = "Service set at completed"
      end
    end

    redirect_to project_service_path(:project_id => params[:project_id], :id => params[:id]), {notice: msg}
  end

  def service_params
    params.require(:service).permit(:location_id, :brand_ambassador_id, :start_at, :end_at, :details)
  end

end