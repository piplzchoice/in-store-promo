class ProjectsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_project_status, :only => [:show, :edit, :update]
  
  authorize_resource class: ProjectsController

  def index
    @projects = Project.all
    respond_to do |format|
      format.html
    end    
  end

  def new
    @project = Project.new
    respond_to do |format|
      format.html
    end    
  end

  def edit
    @project = Project.find(params[:id])
    respond_to do |format|
      format.html
    end    
  end

  def show
    @project = Project.find(params[:id])
    respond_to do |format|
      format.html
    end    
  end

  def create
    @project = Project.new_data(project_params)
    @project.user_id = current_user.id
    respond_to do |format|
      format.html do
        if @project.save
          redirect_to projects_url, notice: "Project created"
        else
          render :new
        end
      end
    end       
  end

  def update
    @project = Project.find(params[:id])
    respond_to do |format|
      format.html do
        if @project.update_data(project_params)
          redirect_to projects_url, notice: "Project updated"
        else
          render :edit
        end
      end
    end

  end

  def destroy
    @project = Project.find(params[:id])
    msg = nil
    if @project.is_active
      @project.set_data_false
      msg = "Project is deactivated"
    else
      @project.set_data_true
      msg = "Project is reactivated"
    end
    redirect_to projects_url, {notice: msg}    
  end

  def project_params
    params.require(:project).permit(:name, :descriptions, :client_id, :rate, :start_at, :end_at)
  end      

  private

  def check_project_status
    project = Project.find(params[:id])
    redirect_to(projects_path, :flash => { :error => "Project is not active" }) unless project.is_active
  end
end
