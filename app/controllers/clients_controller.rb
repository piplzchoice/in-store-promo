class ClientsController < ApplicationController
  before_filter :authenticate_user!
  authorize_resource class: ClientsController

  def index
    @clients = Client.all
    respond_to do |format|
      format.html
    end    
  end

  def new
    @client = Client.new
    @client.build_account
    respond_to do |format|
      format.html
    end    
  end

  def edit
    @client = Client.find(params[:id])
    respond_to do |format|
      format.html
    end    
  end

  def show
    @client = Client.find(params[:id])
    respond_to do |format|
      format.html
    end    
  end

  def create
    @client, password = Client.new_with_account(client_params, current_user.id)
    respond_to do |format|
      format.html do
        if @client.save
          ApplicationMailer.welcome_email(@client.account.email, @client.name ,password).deliver
          redirect_to clients_url, notice: "Client created"
        else
          render :new
        end
      end
    end       
  end

  def update
    @client = Client.find(params[:id])
    respond_to do |format|
      format.html do
        if @client.update_attributes(client_params)
          redirect_to clients_url, notice: "Client updated"
        else
          render :edit
        end
      end
    end

  end

  def destroy
    @client = Client.find(params[:id])
    @account = @client.account
    if @client.destroy && @account.destroy
      redirect_to clients_url, {notice: "Client deleted"}
    end    
  end

  def reset_password
    @client, msg = Client.find(params[:id]), nil
    password = @client.reset_password
    if @client.account.save
      ApplicationMailer.reset_password(@client.account.email, @client.name ,password).deliver
      msg = "Password reset success, new password sent to email"
    else
      msg = "Password reset failed"
    end

    redirect_to clients_url, {notice: msg}
  end

  def autocomplete_client_name
    respond_to do |format|
      format.json do
        render json: Client.all
      end
    end    
  end

  def client_params
    params.require(:client).permit(:company_name, :title, :first_name, :last_name, 
      :street_one, :street_two, :city, :state, :zipcode, :country, :phone, :billing_name, account_attributes: [:email, :id])
  end  

end
