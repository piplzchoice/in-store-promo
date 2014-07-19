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
# 1. invited => this state mean new service has been created and notification has send to BA
# 2. accepted => BA accepted the assignment
# 3. rejected => BA rejected the assignment
# 4. completed => BA delivered service and added report
# 5. unrespond => BA did not respond after 12 hours
#

class Service < ActiveRecord::Base
  belongs_to :user
  belongs_to :brand_ambassador
  belongs_to :location
  belongs_to :project
  has_one :report

  validates :location_id, :brand_ambassador_id, :start_at, :end_at, presence: true

  before_create do |service|
    service.token = Devise.friendly_token
  end

  before_update do |service|
    service.token = Devise.friendly_token unless service.changed_attributes["brand_ambassador_id"].nil?
  end

  def self.status_invited
    return 1
  end

  def self.status_accepted
    return 2
  end

  def self.status_rejected
    return 3
  end

  def self.status_completed
    return 4
  end

  def self.status_unrespond
    return 5
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

  def title_calendar
    return "#{self.location.name} - #{self.brand_ambassador.name}"
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
    end    
  end

  def client_and_companyname
    client = project.client
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
      "Invited"
    when 2
      "Accepted"
    when 3
      "Rejected"
    when 4
      "Completed"
    when 5
      "Unrespond"
    end        
  end

  def time_at
    "#{start_at.strftime("%I:%M%p")} - #{end_at.strftime("%I:%M%p")}"
  end

  def company_name
    project.client.company_name
  end
end
