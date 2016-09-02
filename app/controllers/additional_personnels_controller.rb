class AdditionalPersonnelsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :set_client
  authorize_resource class: AdditionalPersonnelsController

  def index
    @additional_personnels = @client.additional_personnels
    respond_to do |format|
      format.html
    end
  end

  def new
    @additional_personnel = @client.additional_personnels.build
    @additional_personnel.build_account
    respond_to do |format|
      format.html
    end    
  end

  def edit
    @additional_personnel = @client.additional_personnels.find(params[:id])
    respond_to do |format|
      format.html
    end    
  end

  def show
    respond_to do |format|
      format.html
    end    
  end

  def create
    @additional_personnel = AdditionalPersonnel.new_with_account(additional_personnel_params, current_user.id, @client.id)
    respond_to do |format|
      format.html do
        if @additional_personnel.save
          ApplicationMailer.welcome_email(
            @additional_personnel.account.email, 
            @additional_personnel.name , 
            additional_personnel_params["account_attributes"]["password"]
          ).deliver
          
          redirect_to client_additional_personnels_url(@client), notice: "Additional Personnel created"
        else
          @additional_personnel.build_account
          render :new
        end
      end
    end
  end

  def update
    @additional_personnel = @client.additional_personnels.find(params[:id])    
    respond_to do |format|
      format.html do           
        if @additional_personnel.update_data(additional_personnel_params)
          redirect_to client_additional_personnels_url(@client), notice: "Coordinator updated"
        else
          render :edit
        end
      end
    end      
  end

  def destroy
    additional_personnel = @client.additional_personnels.find(params[:id])
    user = additional_personnel.account
    user.destroy
    additional_personnel.destroy
    redirect_to client_additional_personnels_url(@client), {notice: "Success Remove Personnel"}
  end

  private

  def set_client
    @client = Client.find(params[:client_id])
  end

  def additional_personnel_params
    params.require(:additional_personnel).permit(:name, :company, :function_text, account_attributes: [:email, :id, :password, :password_confirmation])
  end
end
