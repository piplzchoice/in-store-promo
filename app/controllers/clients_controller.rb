class ClientsController < ApplicationController
  before_filter :authenticate_user!
  authorize_resource class: ClientsController
end
