class ServicesController < ApplicationController
  before_filter :authenticate_user!, except: [:confirm_respond, :rejected_respond]

  authorize_resource class: ServicesController, except: [:confirm_respond, :rejected_respond]

  def index
    render json: Client.calendar_services(params[:client_id])
  end

  def new
    @client = Client.find(params[:client_id])
    @service = @client.services.build
    respond_to do |format|
      format.html
    end
  end

  def create
    @client = Client.find(params[:client_id])
    @service = @client.services.build_data(service_params, params[:client_id])
    respond_to do |format|
      format.html do
        if @service.save
          @client.set_as_active if @client.services.size == 1
          ApplicationMailer.ba_assignment_notification(@service.brand_ambassador, @service).deliver
          redirect_to client_path(@client), notice: "Service created"
        else
          render :new
        end
      end
    end
  end

  def edit
    @client = Client.find(params[:client_id])
    @service = @client.services.find(params[:id])
    respond_to do |format|
      format.html
    end
  end

  def update
    @client = Client.find(params[:client_id])
    @service = @client.services.find(params[:id])
    old_ba = @service.brand_ambassador
    old_date = @service.date
    old_location_id = @service.location_id
    # is_ba_changed = @service.changed_attributes["brand_ambassador_id"].nil?
    respond_to do |format|
      format.html do
        if @service.can_modify? || current_user.has_role?(:admin)
          if @service.update_data(service_params)
            if @service.can_reassign? || current_user.has_role?(:admin)              
              if old_ba.id != @service.brand_ambassador_id || old_location_id != @service.location_id
                ApplicationMailer.cancel_assignment_notification(old_ba, @service, old_date).deliver 
              end
              ApplicationMailer.ba_assignment_notification(@service.brand_ambassador, @service).deliver
              @service.update_attribute(:status, Service.status_scheduled)
            end
            redirect_to client_service_path({client_id: params[:client_id], id: params[:id]}), notice: "Service Updated" and return
          end
        end
        render :edit
      end
    end
  end

  def show
    @client = Client.find(params[:client_id])
    @service = @client.services.find(params[:id])
  end

  def update_status_after_reported
    @client = Client.find(params[:client_id])
    @service = @client.services.find(params[:id])
    @service.update_attributes({status: params[:service_status]})
    redirect_to client_service_path(client_id: @client.id, id: @service.id)
  end

  def destroy
    @client = Client.find(params[:client_id])
    @service = @client.services.find(params[:id])
    if @service.cancelled
      ApplicationMailer.cancel_assignment_notification(@service.brand_ambassador, @service, @service.date).deliver
      redirect_to client_path(@client), {notice: "Service Cancelled"}
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
    @brand_ambassadors = BrandAmbassador.get_available_people(params[:start_at], params[:end_at], params[:service_id])
    render layout: false
  end

  def confirm_respond
    @client = Client.find(params[:client_id])
    unless @client.nil?
      @service = @client.services.find(params[:id])
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
    @client = Client.find(params[:client_id])
    unless @client.nil?
      @service = @client.services.find(params[:id])
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
    @client = Client.find(params[:client_id])
    unless @client.nil?
      @service = @client.services.find(params[:id])
      unless @service.nil?
        @service.update_attributes({status: Service.status_conducted})
        msg = "Service set at completed"
      end
    end

    redirect_to client_service_path(:client_id => params[:client_id], :id => params[:id]), {notice: msg}
  end

  def service_params
    params.require(:service).permit(:location_id, :brand_ambassador_id, :start_at, :end_at, :details, :status)
  end

  def check_client_status
    client = Client.find(params[:client_id])
    redirect_to(clients_path, :flash => { :error => "Client is not active" }) unless client.is_active
  end

end
