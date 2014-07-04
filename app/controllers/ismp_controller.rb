class IsmpController < ApplicationController
  before_filter :authenticate_user!
  authorize_resource class: IsmpController

  def index
    @users = User.all_ismp
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
        if @user.save_ismp
          redirect_to ismp_index_url, notice: "ISMP created"
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
        if @user.update_ismp(user_params)
          redirect_to ismp_index_url, notice: "ISMP updated"
        else
          render :edit
        end
      end
    end      
  end

  def destroy
    assign_user
    if @user.destroy
      redirect_to ismp_index_url, {notice: "ISMP deleted"}
    end
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

  def assign_user
    @user = User.find(params[:id])
    redirect_to(ismp_index_url, :flash => { :error => "Not ISMP" }) unless @user.has_role?(:ismp)    
  end
end
