class UsersController < ApplicationController
  before_filter :authenticate_user!
  authorize_resource class: UsersController      

  def update
    @user = current_user
    respond_to do |format|
      format.html do           
        if @user.update_data(user_params)
          redirect_to root_path, notice: "User updated"
        else
          render :edit
        end
      end
    end 
  end

  def edit
    @user = current_user
  end  

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end  
end
