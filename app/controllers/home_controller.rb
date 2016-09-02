class HomeController < ApplicationController
  before_filter :authenticate_user!, only: [:index]
  
  def index
  end

  def forgot_password
    @user = User.find_by_email(params[:email_address])

    unless @user.nil?
      User.send_reset_password_instructions(@user) 
    end
  end

end
