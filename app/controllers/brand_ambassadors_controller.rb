class BrandAmbassadorsController < ApplicationController
  before_filter :authenticate_user!
  authorize_resource class: BrandAmbassadorsController
end
