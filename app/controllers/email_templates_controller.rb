class EmailTemplatesController < ApplicationController
  before_filter :authenticate_user!
  authorize_resource class: EmailTemplatesController

  def index
    @email_templates = EmailTemplate.all
  end

  def edit
    @email_template = EmailTemplate.find(params[:id])
  end

  def update
    @email_template = EmailTemplate.find(params[:id])
    respond_to do |format|
      format.html do
        if @email_template.update_attributes(email_template_params)
          redirect_to email_templates_path, notice: "Template updated"
        else
          render :edit
        end
      end
    end    
  end

  def email_template_params
    params.require(:email_template).permit(:subject, :content)
  end    

end
