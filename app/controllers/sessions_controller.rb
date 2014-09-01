class SessionsController < Devise::SessionsController
  def new
    super
  end

  def create
    super
  end

    # DELETE /resource/sign_out
  def destroy
    if session[:prev_current_user_id].nil?
      signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
      set_flash_message :notice, :signed_out if signed_out && is_flashing_format?      
    else
      sign_in(:user, User.find(session[:prev_current_user_id]))
      session[:prev_current_user_id] = nil
    end
    redirect_path = root_path

    # yield resource if block_given?

    respond_to do |format|
      format.all { head :no_content }
      format.any(*navigational_formats) { redirect_to redirect_path }
    end
  end

end