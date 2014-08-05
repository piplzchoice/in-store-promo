class BrandAmbassadorsController < ApplicationController
  before_filter :authenticate_user!
  authorize_resource class: BrandAmbassadorsController

  def index
    @brand_ambassadors = BrandAmbassador.all
    respond_to do |format|
      format.html
    end    
  end

  def new
    @brand_ambassador = BrandAmbassador.new
    @brand_ambassador.build_account
    respond_to do |format|
      format.html
    end    
  end

  def edit
    @brand_ambassador = BrandAmbassador.find(params[:id])
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
          render :edit
        end
      end
    end

  end

  def destroy
    @brand_ambassador = BrandAmbassador.find(params[:id])
    @account = @brand_ambassador.account
    if @brand_ambassador.destroy && @account.destroy
      redirect_to brand_ambassadors_url, {notice: "BA deleted"}
    end    
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
    params.require(:brand_ambassador).permit(:name, :phone ,:address, :grade, :rate, :mileage, account_attributes: [:email, :id])
  end    

  def view_ba_calender
    respond_to do |format|
      format.html
      format.json { render json: BrandAmbassador.get_all_available_dates }
    end
  end
end
