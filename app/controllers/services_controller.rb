class ServicesController < ApplicationController
  before_filter :authenticate_user!, except: [:confirm_respond, :rejected_respond]

  authorize_resource class: ServicesController, except: [:confirm_respond, :rejected_respond, :show]

  def index
    render json: Client.calendar_services(params[:client_id])
  end

  def new
    @client = Client.find(params[:client_id])
    @clients = Client.with_status_active.where.not(id: params[:client_id])
    @service = @client.services.build
    respond_to do |format|
      format.html
    end
  end

  def create
    @client = Client.find(params[:client_id])
    @clients = Client.with_status_active.where.not(id: params[:client_id])
    @service = @client.services.build_data(service_params)
    # @service.product_ids = params[:product_ids]
    respond_to do |format|
      format.html do
        if @service.save
          Log.record_status_changed(@service.id, 0, @service.status, current_user.id)
          unless params["location"].nil?
            @service.location.update_attributes({
              phone: params[:location][:phone],
              contact: params[:location][:contact]
            })
          end
          @service.create_coops(params["co_op_client_id"], params["ids-coop-products"], current_user.id) if params["co-op-price-box"]
          # @client.set_as_active if @client.services.size == 1
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
    @clients = Client.with_status_active.where.not(id: params[:client_id])
    @service = @client.services.find(params[:id])
    respond_to do |format|
      format.html
    end
  end

  def update
    @client = Client.find(params[:client_id])
    @clients = Client.with_status_active.where.not(id: params[:client_id])
    @service = @client.services.find(params[:id])

    respond_to do |format|
      format.html do
        if @service.can_modify? || current_user.has_role?(:admin)
          @service.update_data(service_params, params["co-op-price-box"], params["co_op_client_id"], params["ids-coop-products"], current_user.id)
          redirect_to client_service_path({client_id: params[:client_id], id: params[:id]}), notice: "Service Updated" and return
        end
        render :edit
      end
    end
  end

  def show
    @client = Client.find(params[:client_id])
    @service = @client.services.where(id: params[:id]).first
    @service = @client.co_op_services.where(id: params[:id]).first if @service.nil?
    redirect_to client_path(@client), notice: "Service not found" if @service.nil?
  end

  def logs
    @client = Client.find(params[:client_id])
    @service = @client.services.where(id: params[:service_id]).first
    @service = @client.co_op_services.where(id: params[:service_id]).first if @service.nil?
    redirect_to client_path(@client), notice: "Service not found" if @service.nil?
  end

  def log
    @client = Client.find(params[:client_id])
    @service = @client.services.where(id: params[:service_id]).first
    @service = @client.co_op_services.where(id: params[:service_id]).first if @service.nil?
    @log = Log.find(params[:log_id])
    redirect_to client_path(@client), notice: "Service not found" if @service.nil?
  end

  def update_status_after_reported
    @client = Client.find(params[:client_id])
    @service = @client.services.find(params[:id])
    @service.update_status_both_side(params[:service_status], current_user.id)
    redirect_to client_service_path(client_id: @client.id, id: @service.id)
  end

  def destroy
    @client = Client.find(params[:client_id])
    # @service = @client.services.find(params[:id])
    @service = Service.find(params[:id])
    if @service.cancelled(current_user.id)
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
    @brand_ambassadors = BrandAmbassador.get_available_people(params[:start_at], params[:end_at], params[:service_id], params[:location_id])
    render layout: false
  end

  def confirm_respond
    @client = Client.find(params[:client_id])
    unless @client.nil?
      @service = @client.services.find(params[:id])
      unless @service.nil?
        if Devise.secure_compare(@service.token, params[:token])
          @service.update_status(Service.status_confirmed, current_user.id, Devise.friendly_token)
          ApplicationMailer.send_ics(@service.brand_ambassador, @service).deliver
        end
      end
    end

    redirect_to root_path
    # path = assignment_path(id: @service.id)

    # if current_user.has_role?(:admin) || current_user.has_role?(:ismp)
    #   path = client_service_path(client_id: @client.id, id: @service.id)
    # end

    # redirect_to path
  end

  def rejected_respond
    @client = Client.find(params[:client_id])
    unless @client.nil?
      @service = @client.services.find(params[:id])
      unless @service.nil?
        if Devise.secure_compare(@service.token, params[:token])
          @service.update_status(Service.status_rejected, current_user.id, Devise.friendly_token)
        end
      end
    end

    redirect_to root_path
  end

  # def mark_service_as_complete
  #   msg = "Service update failed"
  #   @client = Client.find(params[:client_id])
  #   unless @client.nil?
  #     @service = @client.services.find(params[:id])
  #     unless @service.nil?
  #       @service.update_status_to_conducted
  #       msg = "Service set at completed"
  #     end
  #   end

  #   redirect_to client_service_path(:client_id => params[:client_id], :id => params[:id]), {notice: msg}
  # end

  def set_reschedule
    msg = "Service reschedule failed"
    @client = Client.find(params[:client_id])
    unless @client.nil?
      @service = @client.services.find(params[:id])
      unless @service.nil?
        @service.update_status_both_side(Service.status_scheduled, current_user.id)
        ApplicationMailer.ba_assignment_notification(@service.brand_ambassador, @service).deliver
        msg = "Service reschedule completed"
      end
    end

    redirect_to client_service_path(:client_id => params[:client_id], :id => params[:id]), {notice: msg}
  end

  def confirm_inventory
    @service = Service.find(params[:service_id])
    @service.update_inventory(service_inventory_params, current_user.id)
    ApplicationMailer.changes_on_your_services(@service).deliver
    redirect_to client_service_path({client_id: params[:client_id], id: params[:service_id]}) and return
  end

  def check_client_status
    client = Client.find(params[:client_id])
    redirect_to(clients_path, :flash => { :error => "Client is not active" }) unless client.is_active
  end

  private

  def service_params
    params.require(:service).permit(:location_id, :brand_ambassador_id, :start_at, :end_at, :details, :status, :is_old_service, :product_ids)
  end

  def service_inventory_params
    params.require(:service).permit(:product_ids, :inventory_confirm, :inventory_date, :inventory_confirmed, :status_inventory)
  end

end
