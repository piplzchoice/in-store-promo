class ProjectsController < ApplicationController
  before_filter :authenticate_user!
  
  authorize_resource class: ProjectsController
end
