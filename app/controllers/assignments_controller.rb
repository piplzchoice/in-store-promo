class AssignmentsController < ApplicationController
  before_filter :authenticate_user!
  authorize_resource class: AssignmentsController  
end
