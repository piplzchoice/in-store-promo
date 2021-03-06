class ProjectsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_project_status, :only => [:show, :edit, :update]

  authorize_resource class: ProjectsController

  def index
    respond_to do |format|
      format.html {
        @projects = Project.with_status_active.paginate(:page => params[:page])
        @clients = Client.all
      }
      format.js {
        @projects = Project.filter_and_order(params[:status], params[:client_name]).paginate(:page => params[:page])
      }
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
      @project.set_as_complete
      msg = "Project is deactivated"
    else
      @project.set_data_true
      if @project.services.size != 0
        @project.set_as_active
      else
        @project.set_as_planned
      end      

      msg = "Project is reactivated"
    end
    redirect_to projects_url, {notice: msg}
  end

  def set_as_complete
    @project = Project.find(params[:id])
    @project.set_as_complete
    @project.set_data_false
    redirect_to projects_url, notice: "Project set as Completed"
  end

  def export_calendar
    @project = Project.find(params[:id])
    @dataurl = params[:dataurl]
    
    file = "project-calendar-#{@project.id}-#{Time.now.to_i}.pdf"
    html = render_to_string(:layout => "print_calendar", :action => "print_calendar", :id => @project.id, :dataurl => @dataurl)
    kit = PDFKit.new(html)
    # kit.stylesheets << "#{Rails.root}/app/assets/stylesheets/application.css.scss"
    send_data(kit.to_pdf, :filename => file, :type => 'application/pdf')    
  end

  def print_calendar    
    @project = Project.find(params[:id])
    @dataurl = params[:dataurl]
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
