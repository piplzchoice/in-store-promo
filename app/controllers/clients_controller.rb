class ClientsController < ApplicationController
  before_filter :authenticate_user!
  authorize_resource class: ClientsController
  before_filter :check_client_status, only: [:show, :edit, :update]

  def index    
    respond_to do |format|
      format.html {        
        if session[:filter_history_clients].nil?
          @clients = Client.with_status_active.paginate(:page => params[:page])
        else
          @clients = Client.filter_and_order(session[:filter_history_clients]["is_active"]).paginate(:page => session[:filter_history_clients]["page"])          
          @is_active = session[:filter_history_clients]["is_active"]
          session[:filter_history_clients] = nil  if request.env["HTTP_REFERER"].nil? || request.env["HTTP_REFERER"].split("/").last == "clients"
        end
      }
      format.js {
        session[:filter_history_clients] = {"is_active" => params[:is_active], "page" => params[:page]}
        @clients = Client.filter_and_order(session[:filter_history_clients]["is_active"]).paginate(:page => session[:filter_history_clients]["page"])
      }      
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
    msg = ""
    if @client.is_active
      @client.set_data_false
      msg = "Client de-activated"      
    else
      @client.set_data_true
      msg = "Client re-activated"      
    end    

    redirect_to clients_url, {notice: msg}
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

  def logged_as
    client = Client.find(params[:id])
    session[:prev_current_user_id] = current_user.id
    sign_in(:user, client.account)    
    redirect_to root_url, {notice: "Login as Client #{client.company_name}"}
  end  

  def autocomplete_client_name
    respond_to do |format|
      format.json do
        render json: Client.autocomplete_search(params[:q])
      end
    end    
  end

  def client_params
    params.require(:client).permit(:company_name, :title, :first_name, :last_name, :rate,
      :street_one, :street_two, :city, :state, :zipcode, :country, :phone, :billing_name, account_attributes: [:email, :id])
  end  

  def export_calendar
    @client = Client.find(params[:id])
    @dataurl = params[:dataurl]
    
    file = "client-calendar-#{@client.id}-#{Time.now.to_i}.pdf"
    html = render_to_string(:layout => "print_calendar", :action => "print_calendar", :id => @client.id, :dataurl => @dataurl)
    kit = PDFKit.new(html)
    # kit.stylesheets << "#{Rails.root}/app/assets/stylesheets/application.css.scss"
    send_data(kit.to_pdf, :filename => file, :type => 'application/pdf')    
  end

  def print_calendar    
    @client = Client.find(params[:id])
    @dataurl = params[:dataurl]
  end  

  def manage_addtional_emails
    @client = Client.find(params[:id])
    respond_to do |format|
      format.html
    end        
  end

  def update_addtional_emails  
    client = Client.find(params[:id])    

    msg = {:error => "Failed update addtional email"}

    if client.additional_emails.nil?
        msg = {:notice => "Addtional email added"}
        client.additional_emails = [params["add-email"]]
        client.save(validate: false)                  
    else
      if client.additional_emails.include?(params["add-email"])
        msg = {:error => "Email already been added"}
      else
        msg = {:notice => "Addtional email added"}
        client.additional_emails.push(params["add-email"])
        client.save(validate: false)            
      end
    end

    redirect_to manage_addtional_emails_client_path(client), :flash => msg
  end

  def remove_addtional_emails
    client = Client.find(params[:id])    

    if client.additional_emails.include?(params["email"])
      client.additional_emails.delete(params["email"])
      client.save(validate: false)
      msg = {:notice => "Email is deleted"}
    else
      msg = {:error => "Email not found"}      
    end    

    redirect_to manage_addtional_emails_client_path(client), :flash => msg
  end

  private
  def check_client_status
    client = Client.find(params[:id])
    redirect_to(clients_path, :flash => { :error => "Client is not active" }) unless client.is_active
  end

end
