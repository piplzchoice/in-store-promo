class ServicesController < ApplicationController
  before_filter :authenticate_user!, except: [:confirm_respond, :rejected_respond]

  authorize_resource class: ServicesController, except: [:confirm_respond, :rejected_respond, :show, :comment_inventory]

  def index
    render json: Client.calendar_services(params)
  end

  def new
    @client = Client.find(params[:client_id])
    @clients = Client.with_status_active.where.not(id: params[:client_id])
    @service = @client.services.build
    respond_to do |format|
      format.html
    end
  end

  def new_tbs
    @client = Client.find(params[:client_id])
    @clients = Client.with_status_active.where.not(id: params[:client_id])
    @service = @client.services.build
    respond_to do |format|
      format.html
    end
  end

  def new_order
    @client = Client.find(params[:client_id])
    @clients = Client.with_status_active.where.not(id: params[:client_id])
    @service = @client.services.build
    respond_to do |format|
      format.html
    end
  end

  def create_tbs
    @client = Client.find(params[:client_id])
    @service = Service.build_data_tbs(params[:service], params[:tbs], params[:client_id], params[:product_ids])
    respond_to do |format|
      format.json do
        @service.order_id = params[:order_id]
        @service.save
        Log.record_status_changed(@service.id, 0, @service.status, current_user.id)
        if params[:index] != ""
          order = @service.order
          order.service_copy.delete_at(params[:index].to_i)
          order.save
        end
        render json: @service.format_react_component
      end

      format.html do
        if @service.save
          Log.record_status_changed(@service.id, 0, @service.status, current_user.id)
          unless params["location"].nil?
            @service.location.update_attributes({
              phone: params[:location][:phone],
              contact: params[:location][:contact]
            })
          end

          if params["co-op-price-box"]
            @service.create_coops_tbs(
              params[:service],
              params[:tbs],
              params["co_op_client_id"],
              params["ids-coop-products"],
              @service.id,
              current_user.id
            )
          end

          redirect_to client_service_path(client_id: @client.id, id: @service.id), notice: "Demo Scheduled Created"
        end
      end
    end
  end

  def add_coop_demo
    @client = Client.find(params[:client_id])
    @service = @client.services.find(params[:id])
    @service.create_coops(params["co_op_client_id"], params["ids-coop-products"], current_user.id)

    redirect_to client_service_path(client_id: @client.id, id: @service.id), notice: "Coop Update"
  end

  def request_by_phone
    @client = Client.find(params[:client_id])
    @service = @client.services.find(params[:id])

    data = {
      datetime: DateTime.strptime(params[:request][:datetime], '%m/%d/%Y %I:%M %p'),
      name: params[:request][:name],
      conversation: params[:request][:conversation]
    }

    Log.record_phone_request(@service.id, data, current_user.id)

    if @service.is_co_op?
      coop_service = @service.coop_service
      Log.record_phone_request(coop_service.id, data, current_user.id)
    end

    redirect_to client_service_path(client_id: @client.id, id: @service.id), notice: "Request by phone data saved"
  end

  def request_by_email
    @client = Client.find(params[:client_id])
    @service = @client.services.find(params[:id])

    data = {
      date_sent: DateTime.now.strftime('%m/%d/%Y %I:%M %p'),
      subject: params[:request][:subject],
      content: params[:request][:content]
    }

    unless params[:request][:email].nil?
      loc = @service.location
      loc.email = params[:request][:email]
      loc.save
    end

    log_id = Log.record_email_request(@service.id, data, current_user.id)

    if @service.is_co_op?
      coop_service = @service.coop_service
      Log.record_email_request(coop_service.id, data, current_user.id)
    end

    ApplicationMailer.demo_request(@service.id, log_id).deliver
    redirect_to client_service_path(client_id: @client.id, id: @service.id), notice: "Request by email sent"
  end

  def change_to_schedule
    @client = Client.find(params[:client_id])
    @service = @client.services.find(params[:id])
    if @service.is_co_op?
      if @service.co_op_services.empty?
        @service = @service.parent
      else
        @service = @service
      end
    else
      @service = @service
    end

    @service.update_to_scheduled(params["changed_tbs"])

    Log.record_status_changed(@service.id, 12, @service.status, current_user.id)
    if @service.is_co_op?
      coop_service = @service.coop_service
      Log.record_status_changed(coop_service.id, 12, coop_service.status, current_user.id)
    end

    ApplicationMailer.ba_assignment_notification(@service.brand_ambassador.id, @service.id).deliver

    redirect_to client_service_path(client_id: @client.id, id: @service.id), notice: "Service change to status Scheduled"
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
          ApplicationMailer.ba_assignment_notification(@service.brand_ambassador.id, @service.id).deliver
          redirect_to client_path(@client), notice: "Demo created"
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
          redirect_to client_service_path({client_id: params[:client_id], id: params[:id]}), notice: "Demo Updated" and return
        end
        render :edit
      end
    end
  end

  def show
    @client = Client.find(params[:client_id])
    @clients = Client.with_status_active.where.not(id: params[:client_id])
    @service = @client.services.where(id: params[:id]).first
    @service = @client.co_op_services.where(id: params[:id]).first if @service.nil?
    redirect_to client_path(@client), notice: "Demo not found" if @service.nil?
  end

  def logs
    @client = Client.find(params[:client_id])
    @service = @client.services.where(id: params[:service_id]).first
    @service = @client.co_op_services.where(id: params[:service_id]).first if @service.nil?
    redirect_to client_path(@client), notice: "Demo not found" if @service.nil?
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

      # ApplicationMailer.cancel_assignment_notification(
      #   @service.brand_ambassador, 
      #   @service, 
      #   @service.date
      # ).deliver unless @service.status == 12

      redirect_to client_path(@client), {notice: "Demo Cancelled"}
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

  def generate_select_ba_tbs

    if params[:react] == "true"
      start_at_first = params[:first_date][:start_at]
      end_at_first = params[:first_date][:end_at]

      unless params[:no_need_second_date] == "true"
        start_at_second = params[:second_date][:start_at]
        end_at_second = params[:second_date][:end_at]
      end

    else
      start_at_first = params[:tbs_start_at_first]
      end_at_first = params[:tbs_end_at_first]
      start_at_second = params[:tbs_start_at_second]
      end_at_second = params[:tbs_end_at_second]
    end

    ba_first_tbs = BrandAmbassador.get_available_people(
      start_at_first, end_at_first,
      params[:service_id], params[:location_id]
    )

    ba_ids = []
    ba_ids.push ba_first_tbs.collect(&:id)

    unless params[:no_need_second_date] == "true"
      ba_second_tbs = BrandAmbassador.get_available_people(
        start_at_second, end_at_second,
        params[:service_id], params[:location_id]
      )
      ba_ids.push ba_second_tbs.collect(&:id)
    end

    ba_ids = ba_ids.flatten.uniq

    @brand_ambassadors = BrandAmbassador.find(ba_ids)

    respond_to do |format|
      format.html {
        render layout: false
      }

      format.json{
        render json: @brand_ambassadors
      }
    end


  end

  def get_data_ids
    ba = {}
    unless params[:ba_ids].nil? && params[:location_id].nil?
      if params[:status] == "0" || params[:status] == "12"
        second_ba = BrandAmbassador.find(params[:ba_ids].last).name
      else
        second_ba = "-"
      end

      ba = {
        first_ba: BrandAmbassador.find(params[:ba_ids].first).name,
        second_ba: second_ba,
      }
    end

    respond_to do |format|
      format.json{
        render json: {
          location_name: Location.find(params[:location_id]).complete_location
        }.merge(ba)
      }
    end
  end

  def confirm_respond
    @client = Client.find(params[:client_id])
    unless @client.nil?
      @service = @client.services.find(params[:id])
      unless @service.nil?
        if Devise.secure_compare(@service.token, params[:token])
          @service.update_status(Service.status_confirmed, @service.brand_ambassador.account.id, Devise.friendly_token)
          ApplicationMailer.send_ics(@service.brand_ambassador.id, @service.id).deliver
        end
      end
    end

    @respond_service = "true"
    render "respond_service"
  end

  def rejected_respond
    @client = Client.find(params[:client_id])
    unless @client.nil?
      @service = @client.services.find(params[:id])
      unless @service.nil?
        if Devise.secure_compare(@service.token, params[:token])
          @service.update_status(Service.status_rejected, @service.brand_ambassador.account.id, Devise.friendly_token)
          ApplicationMailer.rejected_service(@service.id).deliver
        end
      end
    end

    @respond_service = "true"
    render "respond_service"
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
    msg = "Demo reschedule failed"
    @client = Client.find(params[:client_id])
    unless @client.nil?
      @service = @client.services.find(params[:id])
      unless @service.nil?
        @service.update_status_both_side(Service.status_scheduled, current_user.id)
        ApplicationMailer.ba_assignment_notification(@service.brand_ambassador.id, @service.id).deliver
        msg = "Demo reschedule completed"
      end
    end

    redirect_to client_service_path(:client_id => params[:client_id], :id => params[:id]), {notice: msg}
  end

  def confirm_inventory
    @service = Service.find(params[:service_id])
    @service.update_inventory(service_inventory_params, current_user.id)
    ApplicationMailer.changes_on_your_services(@service.id).deliver unless @service.status == 12
    redirect_to client_service_path({client_id: params[:client_id], id: params[:service_id]}) and return
  end

  def comment_inventory
    @service = Service.find(params[:service_id])
    cur_user_id = current_user.id
    cur_user_id = session[:additional_personnel].id unless session[:additional_personnel].nil?
    Log.record_comment_of_inventory(@service.id, params[:comments], cur_user_id)
    redirect_to client_service_path({client_id: @service.client_id, id: params[:service_id]}) and return
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
