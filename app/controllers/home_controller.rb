class HomeController < ApplicationController
  before_filter :authenticate_user!, only: [:index]
  
  def index
  end

  def forgot_password
    @user = User.where({email: params[:email_address]})

    unless @user.blank?
      @user.first.send_reset_password_instructions 
    end
  end

end
