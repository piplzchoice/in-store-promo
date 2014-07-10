class DefaultValuesController < ApplicationController
  before_filter :authenticate_user!
  authorize_resource class: DefaultValuesController

  def edit
    @default_value = DefaultValue.first
    respond_to do |format|
      format.html
    end    
  end

  def update
    @default_value = DefaultValue.first
    respond_to do |format|
      format.html do           
        if @default_value.update_attributes(default_value_params)
          redirect_to edit_default_value_url, id: @default_value.id, notice: "Default Values updated"
        else
          render :edit
        end
      end
    end      
  end

  def default_value_params
    params.require(:default_value).permit(:rate_project)
  end

end
