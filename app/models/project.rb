# == Schema Information
#
# Table name: projects
#
#  id           :integer          not null, primary key
#  user_id      :integer
#  client_id    :integer
#  name         :string(255)
#  descriptions :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#  start_at     :date
#  end_at       :date
#  rate         :decimal(8, 2)
#

class Project < ActiveRecord::Base
  belongs_to :user
  belongs_to :client
  has_many :services

  validates :name, :descriptions, :client_id, presence: true

  def self.new_data(project_params)
    project_params[:start_at] = Date.strptime(project_params[:start_at], '%m/%d/%Y') unless project_params[:start_at].blank?
    project_params[:end_at] = Date.strptime(project_params[:end_at], '%m/%d/%Y')  unless project_params[:end_at].blank?
    self.new(project_params)    
  end

  def self.calendar_services(project_id)
    project = find(project_id)
    project.services.collect{|x| {
        title: x.title_calendar, 
        start: x.start_at.strftime("%Y-%m-%dT%H:%M:%S"), 
        end: x.end_at.strftime("%Y-%m-%dT%H:%M:%S"),
        url: Rails.application.routes.url_helpers.project_service_path({project_id: project_id, id: x.id})
      } }
  end

  def update_data(project_params)
    project_params[:start_at] = Date.strptime(project_params[:start_at], '%m/%d/%Y') unless project_params[:start_at].blank?
    project_params[:end_at] = Date.strptime(project_params[:end_at], '%m/%d/%Y')  unless project_params[:end_at].blank?    
    self.update_attributes(project_params)    
  end
end
