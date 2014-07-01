class LocationsController < ApplicationController
  before_filter :authenticate_user!
  
  authorize_resource class: LocationsController
end
