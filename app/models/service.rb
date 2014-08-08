# == Schema Information
#
# Table name: services
#
#  id                  :integer          not null, primary key
#  project_id          :integer
#  location_id         :integer
#  brand_ambassador_id :integer
#  user_id             :integer
#  created_at          :datetime
#  updated_at          :datetime
#  start_at            :datetime
#  end_at              :datetime
#  details             :text
#  status              :integer          default(1)
#  token               :string(255)
#

# note for field "status"
# 1. Scheduled => this state mean new service has been created and notification has send to BA
# 2. Confirmed => BA accepted the assignment
# 3. rejected => BA rejected the assignment
# 4. Conducted => BA delivered service and added report
# 5. unrespond => BA did not respond after 12 hours
# 6. Reported => when report is created
# 7. Paid => when service has been paid
# 8. BA Paid => 
# 9. Cancelled
#

class Service < ActiveRecord::Base
  belongs_to :user
  belongs_to :brand_ambassador
  belongs_to :location
  belongs_to :project
  has_one :report

  has_one :client, :through => :project

  validates :location_id, :brand_ambassador_id, :start_at, :end_at, presence: true

  before_create do |service|
    service.token = Devise.friendly_token
  end

  before_update do |service|
    service.token = Devise.friendly_token unless service.changed_attributes["brand_ambassador_id"].nil?
  end

  def self.filter_and_order(status, assigned_to, client_name, project_name, sort_column, sort_direction)
    data = nil
    conditions = {}
    conditions.merge!(status: status) if status != ""
    conditions.merge!(brand_ambassador_id: assigned_to) if assigned_to != ""
    conditions.merge!(project_id: project_name) if project_name != ""
    
    if client_name != ""
      data = Service.joins(:client).where(clients: {id: client_name}).where(conditions)
    else
      data = Service.where(conditions)
    end        

    if sort_column == "ba"
      data = data.joins(:brand_ambassador).order("brand_ambassadors.name #{sort_direction}")
    elsif sort_column == "client"
      data = data.joins(:client).order("clients.company_name #{sort_direction}")
    else
      if sort_column == "time"
        data = data.order("EXTRACT (HOUR from start_at) #{sort_direction}")
      else
        data = data.order(sort_column + " " + sort_direction)
      end      
    end

    return data
  end

  def self.status_scheduled
    return 1
  end

  def self.status_confirmed
    return 2
  end

  def self.status_rejected
    return 3
  end

  def self.status_conducted
    return 4
  end

  def self.status_unrespond
    return 5
  end      

  def self.status_reported
    return 6
  end      

  def self.status_paid
    return 7
  end       

  def self.status_ba_paid
    return 8
  end         

  def self.status_cancelled
    return 9
  end         

  def self.send_notif_after
    return 2.round
  end

  def self.build_data(service_params)
    service_params[:start_at] = DateTime.strptime(service_params[:start_at], '%m/%d/%Y %I:%M %p') unless service_params[:start_at].blank?
    service_params[:end_at] = DateTime.strptime(service_params[:end_at], '%m/%d/%Y %I:%M %p')  unless service_params[:end_at].blank?
    self.new(service_params)
  end

  def self.invited_and_unrespond_status
    # where status = 1 and created_at >= 12 hours
    # update status to 5 and send notification to admin
  end

  def self.options_select_after_reported
    [["Paid", Service.status_paid], ["BA Paid", Service.status_ba_paid]]
  end

  def self.options_select_status
    [
      ["Scheduled", Service.status_scheduled], 
      ["BA Confirmed", Service.status_confirmed], 
      ["Conducted", Service.status_conducted], 
      ["Reported", Service.status_reported], 
      ["Paid", Service.status_paid], 
      ["BA paid", Service.status_ba_paid], 
      ["Cancelled", Service.status_cancelled]
    ]
  end

  def self.calendar_services(status, assigned_to, client_name, project_name, sort_column, sort_direction)
    Service.filter_and_order(status, assigned_to, client_name, project_name, sort_column, sort_direction).collect{|x| {
        title: x.title_calendar, 
        start: x.start_at.iso8601, 
        end: x.end_at.iso8601,
        color: x.get_color,
        url: Rails.application.routes.url_helpers.project_service_path({project_id: x.project_id, id: x.id})
      } }
  end  

  def title_calendar
    return "#{(self.location.nil? ? "" : self.location.name)} - #{(self.brand_ambassador.nil? ? "-" : self.brand_ambassador.name)}"
  end

  def update_data(service_params)
    service_params[:start_at] = DateTime.strptime(service_params[:start_at], '%m/%d/%Y %I:%M %p') unless service_params[:start_at].blank?
    service_params[:end_at] = DateTime.strptime(service_params[:end_at], '%m/%d/%Y %I:%M %p')  unless service_params[:end_at].blank?    
    self.update_attributes(service_params)
  end

  def old_id
    ret = nil
    unless self.id.nil?
      service = Service.find self.id
      ret = service.brand_ambassador_id
    else
      ret == nil
    end
    return ret
  end

  def get_color
    case status
    when 1
      "#428bca"
    when 2
      "#5bc0de"
    when 3
      "#f0ad4e"
    when 4
      "#5cb85c"
    when 5
      "#d9534f"
    when 6
      "#dff0d8"
    when 7
      "#3c763d"
    when 8
      "#8a6d3b"   
    when 9
      "#B49C1D"
    end        
  end

  def client_and_companyname
    "#{client.name}/#{client.company_name}"
  end

  def date
    start_at.strftime("%m/%d/%Y")
  end

  def complete_date_time
    "#{start_at.strftime("%m/%d/%Y")} - #{start_at.strftime("%I:%M %p")}/#{end_at.strftime("%I:%M %p")}"
  end  

  def current_status
    case status
    when 1
      "Scheduled"
    when 2
      "Confirmed"
    when 3
      "Rejected"
    when 4
      "Conducted"
    when 5
      "Unrespond"
    when 6
      "Reported"
    when 7
      "Paid"
    when 8
      "BA Paid"
    when 9
      "Cancelled"
    end        
  end

  def time_at
    "#{start_at.strftime("%I:%M%p")} - #{end_at.strftime("%I:%M%p")}"
  end

  def company_name
    client.company_name
  end

  def cancelled
    if can_modify?
      update_attribute(:status, Service.status_cancelled)
    end
  end

  def can_modify?
    [Service.status_scheduled, Service.status_confirmed, Service.status_rejected, 
      Service.status_unrespond].include?(status)
  end

  def can_reassign?
    self.status == Service.status_rejected || self.status == Service.status_unrespond
  end

  def is_not_complete?
    [Service.status_scheduled, Service.status_confirmed, Service.status_rejected, 
      Service.status_unrespond].include?(status)
  end

  def is_cancelled?
    Service.status_cancelled == status
  end

  def is_reported?
    [Service.status_reported, Service.status_paid, Service.status_ba_paid].include?(status)
  end

  def can_create_report?
    [Service.status_conducted, Service.status_paid, Service.status_ba_paid].include?(status)
  end


end

# status_reported
# status_paid
# status_ba_paid
# status_cancelled