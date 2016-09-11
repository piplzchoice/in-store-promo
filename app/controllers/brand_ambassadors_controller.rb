class BrandAmbassadorsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_user_role, only: [:show, :new, :create, :edit, :update]
  authorize_resource class: BrandAmbassadorsController

  def index
    respond_to do |format|
      format.html {
        @locations = Location.with_status_active
        if session[:filter_history_ba].nil?
          @brand_ambassadors = BrandAmbassador.with_status_active.paginate(:page => params[:page])
        else
          @brand_ambassadors = BrandAmbassador.filter_and_order(session[:filter_history_ba]).paginate(:page => session[:filter_history_ba]["page"])
          @is_active = session[:filter_history_ba]["is_active"]
          @location_name = session[:filter_history_ba]["location_name"]

          unless @location_name == ""
            if @location_name.to_i != 0
              @location_fullname = Location.find(@location_name).name
            else
              @location_fullname = @location_name
            end
          end
                    
          session[:filter_history_ba] = nil if request.env["HTTP_REFERER"].nil? || request.env["HTTP_REFERER"].split("/").last == "brand_ambassadors"
        end
      }
      format.js {
        session[:filter_history_ba] = {
          "is_active" => params[:is_active], 
          "page" => params[:page], 
          "location_name" => (params[:location_id] == "987654321" ? params[:location_name] : params[:location_id]),
        }

        @brand_ambassadors = BrandAmbassador.filter_and_order(session[:filter_history_ba])

        unless @brand_ambassadors.blank?
          @brand_ambassadors = @brand_ambassadors.paginate(:page => session[:filter_history_ba]["page"])
        end
      }
    end
  end

  def new
    @brand_ambassador = BrandAmbassador.new
    @territories = Territory.all
    @brand_ambassador.build_account
    respond_to do |format|
      format.html
    end
  end

  def edit
    @brand_ambassador = BrandAmbassador.find(params[:id])
    @territories = Territory.all
    respond_to do |format|
      format.html
    end
  end

  def show
    @brand_ambassador = BrandAmbassador.find(params[:id])
    @statements = @brand_ambassador.statements.order(created_at: :desc)
    respond_to do |format|
      format.html
    end
  end

  def create
    @brand_ambassador, password = BrandAmbassador.new_with_account(brand_ambassador_params, current_user.id)
    respond_to do |format|
      format.html do
        if @brand_ambassador.save
          ApplicationMailer.welcome_email(@brand_ambassador.account.email, @brand_ambassador.name ,password).deliver
          redirect_to brand_ambassadors_url, notice: "BA created"
        else
          @territories = Territory.all
          render :new
        end
      end
    end
  end

  def update
    @brand_ambassador = BrandAmbassador.find(params[:id])
    respond_to do |format|
      format.html do
        if @brand_ambassador.update_attributes(brand_ambassador_params)
          redirect_to brand_ambassadors_url, notice: "BA updated"
        else
          @territories = Territory.all
          render :edit
        end
      end
    end

  end

  def destroy
    @brand_ambassador = BrandAmbassador.find(params[:id])
    msg = nil
    if @brand_ambassador.is_active
      if @brand_ambassador.services.can_be_disable?
        @brand_ambassador.update_attribute(:is_active, false)
        msg = "BA is deactivated"
      else
        msg = "This BA has outstanding demo/payment and cannot be deactivated before it is finalized"
      end
    else
      @brand_ambassador.update_attribute(:is_active, true)
      msg = "BA is reactivated"
    end
    redirect_to brand_ambassadors_url, {notice: msg}
  end


  def availability
    @brand_ambassador = BrandAmbassador.find(params[:id])
    respond_to do |format|
      format.html
      format.json { render json: @brand_ambassador.available_calendar}
    end
  end

  def logged_as
    brand_ambassador = BrandAmbassador.find(params[:id])
    session[:prev_current_user_id] = current_user.id
    sign_in(:user, brand_ambassador.account)
    redirect_to root_url, {notice: "Login as BA #{brand_ambassador.name}"}
  end

  def reset_password
    @brand_ambassador, msg = BrandAmbassador.find(params[:id]), nil
    password = @brand_ambassador.reset_password
    if @brand_ambassador.account.save
      ApplicationMailer.reset_password(@brand_ambassador.account.email, @brand_ambassador.name ,password).deliver
      msg = "Password reset success, new password sent to email"
    else
      msg = "Password reset failed"
    end

    redirect_to brand_ambassadors_url, {notice: msg}
  end

  def new_location
    @brand_ambassador = BrandAmbassador.find(params[:id])
    respond_to do |format|
      format.html {
        @location_ids = @brand_ambassador.location_ids.map(&:to_s)
        @locations = Location.with_status_active.paginate(:page => params[:page])
      }
      format.js {
        @location_ids = (params[:location_ids] == "" ? [] : params[:location_ids].split(","))        
        @locations = Location.filter_and_order(params.merge({is_active: true})).paginate(:page => params[:page])
      }
    end
  end

  def create_location
    @brand_ambassador = BrandAmbassador.find(params[:id])
    @brand_ambassador.location_ids = params[:location_ids].split(",")
    if @brand_ambassador.save
      msg = "Location added"
    else
      msg = "Failed add location"
    end

    redirect_to brand_ambassador_url(id: @brand_ambassador), {notice: msg}
  end

  def destroy_location
  end

  def brand_ambassador_params
    params.require(:brand_ambassador).permit(:name, :phone ,:address, :grade, :rate, :mileage, :territory_ids => [], account_attributes: [:email, :id], :location_ids => [])
  end

  def view_ba_calender
    respond_to do |format|
      format.html {
        @location_name = params[:location_name].nil? ? "0" : params[:location_name]
      }
      format.json { render json: BrandAmbassador.get_all_available_dates(params[:location_name]) }
    end
  end

  private
  def check_user_role
    redirect_to(brand_ambassadors_url, :flash => { :error => "Not allowed" }) if current_user.has_role?(:coordinator)
  end  
end
