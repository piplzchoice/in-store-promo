class BrandAmbassadorsController < ApplicationController
  before_filter :authenticate_user!
  authorize_resource class: BrandAmbassadorsController

  def index
    respond_to do |format|
      format.html {        
        if session[:filter_history_ba].nil?
          @brand_ambassadors = BrandAmbassador.with_status_active.paginate(:page => params[:page])
        else
          @brand_ambassadors = BrandAmbassador.filter_and_order(session[:filter_history_ba]["is_active"]).paginate(:page => session[:filter_history_ba]["page"])
          @is_active = session[:filter_history_ba]["is_active"]
          session[:filter_history_ba] = nil if request.env["HTTP_REFERER"].nil? || request.env["HTTP_REFERER"].split("/").last == "brand_ambassadors"
        end        
      }
      format.js {
        session[:filter_history_ba] = {"is_active" => params[:is_active], "page" => params[:page]}
        @brand_ambassadors = BrandAmbassador.filter_and_order(session[:filter_history_ba]["is_active"]).paginate(:page => session[:filter_history_ba]["page"])
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
      @brand_ambassador.update_attribute(:is_active, false)
      msg = "BA is deactivated"
    else
      @brand_ambassador.update_attribute(:is_active, true)
      msg = "BA is reactivated"
    end
    redirect_to brand_ambassadors_url, {notice: msg}
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

  def brand_ambassador_params
    params.require(:brand_ambassador).permit(:name, :phone ,:address, :grade, :rate, :mileage, :territory_ids => [], account_attributes: [:email, :id])
  end    

  def view_ba_calender
    respond_to do |format|
      format.html
      format.json { render json: BrandAmbassador.get_all_available_dates }
    end
  end
end
