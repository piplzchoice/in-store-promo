class CoordinatorController < ApplicationController
  before_filter :authenticate_user!
  authorize_resource class: CoordinatorController

  def index
    @users = User.all_coordinator
    respond_to do |format|
      format.html
    end
  end

  def new
    @user = User.new
    respond_to do |format|
      format.html
    end    
  end

  def edit
    assign_user
    respond_to do |format|
      format.html
    end    
  end

  def show
    assign_user
    respond_to do |format|
      format.html
    end    
  end

  def create
    @user = User.new(user_params)
    respond_to do |format|
      format.html do
        if @user.save_coordinator
          redirect_to coordinator_index_url, notice: "Coordinator created"
        else
          render :new
        end
      end
    end    
  end

  def update
    assign_user
    respond_to do |format|
      format.html do           
        if @user.update_coordinator(user_params)
          redirect_to coordinator_index_url, notice: "Coordinator updated"
        else
          render :edit
        end
      end
    end      
  end

  def destroy
    assign_user    
    if @user.is_active
      @user.set_data_false
      msg = "Coordinator de-activated"
    else      
      @user.set_data_true
      msg = "Coordinator re-activated"
    end
    redirect_to coordinator_index_url, {notice: msg}
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

  def assign_user
    @user = User.find(params[:id])
    redirect_to(coordinator_index_url, :flash => { :error => "Not Coordinator" }) unless @user.has_role?(:coordinator)    
  end
end
