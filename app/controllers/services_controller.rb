class ServicesController < ApplicationController
  before_filter :authenticate_user!
  
  authorize_resource class: ServicesController
end
