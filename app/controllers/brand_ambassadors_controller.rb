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

  def brand_ambassador_params
    params.require(:brand_ambassador).permit(:name, :phone ,:address, :grade, :rate, :mileage, account_attributes: [:email, :id])
  end    
end
