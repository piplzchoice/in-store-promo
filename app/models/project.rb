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
#  is_active    :boolean          default(TRUE)
#  status       :integer          default(1)
#

# note for field "status"
# 1. Planned => default status for new created project
# 2. Active => When a first service is created
# 3. Completed => Project is completed (only Admin/ISMP can change this)

class Project < ActiveRecord::Base

  belongs_to :user
  belongs_to :client
  has_many :services

  validates :name, :descriptions, :client_id, presence: true
  default_scope { order("created_at ASC") }
  scope :with_status_active, -> { where(status: Project.status_active) }

  def self.status_planned
    return 1
  end

  def self.status_active
    return 2
  end

  def self.status_completed
    return 3
  end

  def self.new_data(project_params)
    project_params[:start_at] = Date.strptime(project_params[:start_at], '%m/%d/%Y') unless project_params[:start_at].blank?
    project_params[:end_at] = Date.strptime(project_params[:end_at], '%m/%d/%Y')  unless project_params[:end_at].blank?
    self.new(project_params)
  end

  def self.calendar_services(project_id)
    project = find(project_id)
    project.services.collect{|x|       
      {
        title: x.title_calendar,
        start: x.start_at.iso8601,
        end: x.end_at.iso8601,
        color: x.get_color,
        url: Rails.application.routes.url_helpers.project_service_path({project_id: project_id, id: x.id})
      } if x.is_ba_active?
    }.uniq.compact
  end

  def self.options_select_status
    [
      ["Planned", Project.status_planned],
      ["Active", Project.status_active],
      ["Completed", Project.status_completed]
    ]
  end

  def self.filter_and_order(status, client_name)
    data = nil
    conditions = {}    
    if status != ""
      conditions.merge!(status: status) 
    else
      conditions.merge!(status: Project.status_active) 
    end

    if client_name != ""
      data = Project.joins(:client).where(clients: {id: client_name}).where(conditions)
    else
      data = Project.where(conditions)
    end

    return data
  end

  def current_status
    case status
    when 1
      "Planned"
    when 2
      "Active"
    when 3
      "Completed"
    end
  end

  def update_data(project_params)
    project_params[:start_at] = Date.strptime(project_params[:start_at], '%m/%d/%Y') unless project_params[:start_at].blank?
    project_params[:end_at] = Date.strptime(project_params[:end_at], '%m/%d/%Y')  unless project_params[:end_at].blank?
    self.update_attributes(project_params)
  end

  def set_data_true
    self.update_attribute(:is_active, true)
  end

  def set_data_false
    self.update_attribute(:is_active, false)
  end

  def set_as_complete
    self.update_attribute(:status, Project.status_completed)
  end

  def set_as_active
    self.update_attribute(:status, Project.status_active)
  end

  def set_as_planned
    self.update_attribute(:status, Project.status_planned)
  end

  def is_not_complete?
    self.status != Project.status_completed
  end
end
