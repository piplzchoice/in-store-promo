# == Schema Information
#
# Table name: services
#
#  id                  :integer          not null, primary key
#  project_id          :integer
#  location_id         :integer
#  brand_ambassador_id :integer
#  created_at          :datetime
#  updated_at          :datetime
#  start_at            :datetime
#  end_at              :datetime
#  details             :text
#  status              :integer          default(1)
#  token               :string(255)
#  is_active           :boolean          default(TRUE)
#  client_id           :integer
#  co_op_client_id     :integer
#

# note for field "status"
# 1. Scheduled => this state mean new service has been created and notification has send to BA ---> "#8DB4E3"
# 2. Confirmed => BA accepted the assignment ---> "#92D050"
# 3. rejected => BA rejected the assignment ---> "#FFFF00"
# 4. Conducted => BA delivered service and added report ---> "#0070C0"
# 5. unrespond => BA did not respond after 12 hours ---> "#A5A5A5"
# 6. Reported => when report is created ---> "#FFC000"
# 7. Paid => when service has been paid ---> "#00B050"
# 8. BA Paid => ---> "#E46D0A"
# 9. Cancelled ---> "#FF0000"
# 10. Invoiced

class Service < ActiveRecord::Base

  belongs_to :client
  belongs_to :project
  belongs_to :brand_ambassador
  belongs_to :location
  has_one :report

  belongs_to :co_op_client, :class_name => "Client", foreign_key: 'co_op_client_id'

  validates :location_id, :brand_ambassador_id, :start_at, :end_at, presence: true

  before_create do |service|
    service.token = Devise.friendly_token
  end

  before_update do |service|
    service.token = Devise.friendly_token unless service.changed_attributes["brand_ambassador_id"].nil?
  end


  def self.filter_and_order(parameters)
    data = nil
    conditions = {}
    conditions.merge!(status: parameters["status"]) if parameters["status"] != ""
    conditions.merge!(brand_ambassador_id: parameters["assigned_to"]) if parameters["assigned_to"] != ""

    if parameters["client_name"] != ""
      data = Service.joins(:client).where(clients: {id: parameters["client_name"]}).where(conditions)
    else
      data = Service.where(conditions)
    end

    if parameters["sort_column"] == "ba"
      data = data.joins(:brand_ambassador).order("brand_ambassadors.name #{parameters["sort_direction"]}")
    elsif parameters["sort_column"] == "client"
      data = data.joins(:client).order("clients.company_name #{parameters["sort_direction"]}")
    elsif parameters["sort_column"] == "location_name"
      data = data.joins(:location).order("locations.name #{parameters["sort_direction"]}")      
    else
      if parameters["sort_column"] == "time"
        data = data.order("EXTRACT (HOUR from start_at) #{parameters["sort_direction"]}")
      else
        data = data.order("#{parameters["sort_column"]} #{parameters["sort_direction"]}")
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

  def self.status_invoiced
    return 10
  end

  def self.send_notif_after
    return 12.round
  end

  def self.build_data(service_params, co_op_price_box)
    service_params[:co_op_client_id] = nil unless co_op_price_box
    if service_params[:start_at].blank? || service_params[:end_at].blank?
      self.new(service_params)
    else
      service_params[:start_at] = DateTime.strptime(service_params[:start_at], '%m/%d/%Y %I:%M %p')
      service_params[:end_at] = DateTime.strptime(service_params[:end_at], '%m/%d/%Y %I:%M %p')

      # service = Service.where({
      #   client_id: service_params[:client_id], 
      #   location_id: service_params[:location_id], 
      #   brand_ambassador_id: service_params[:brand_ambassador_id],
      #   start_at: service_params[:start_at],
      #   end_at: service_params[:end_at]
      # })    

      # if service.blank?
        self.new(service_params)
      # else
      #   self.new
      # end          
    end  
  end

  def self.calculate_total_ba_paid(service_ids)
    total_paid = 0
    Service.find(service_ids).each do |service|
      total_paid += service.total_ba_paid
    end
    return total_paid
  end

  def self.update_to_ba_paid(service_ids)
    Service.find(service_ids).each do |service|
      service.update_attribute(:status, Service.status_ba_paid)
    end    
  end

  def self.update_status_to_paid(service_id)
    service = Service.find(service_id)
    service.update_attribute(:status, Service.status_paid)
  end  

  def self.update_status_to_invoiced(service_id)
    service = Service.find(service_id)
    service.update_attribute(:status, Service.status_invoiced)
  end  

  def self.update_status_to_ba_paid(service_id)
    service = Service.find(service_id)
    # ApplicationMailer.ba_is_paid(@client.account.email, @client.name ,password).deliver
    # service.update_attribute(:status, Service.status_ba_paid)
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

  def self.options_select_status_client
    [
      ["BA Confirmed", Service.status_confirmed],
      ["Conducted", Service.status_conducted],
      ["Reported", Service.status_reported],
      ["Paid", Service.status_paid],
      ["BA paid", Service.status_ba_paid],
    ]
  end

  def self.calendar_services(status, assigned_to, client_name, sort_column, sort_direction)
    data = {"status" => status, "assigned_to" => assigned_to, "client_name" => client_name, "sort_column" => sort_column, "sort_direction" => sort_direction}
    Service.filter_and_order(data).collect{|x|
        if x.status != Service.status_cancelled
          {
            title: x.title_calendar,
            start: x.start_at.iso8601,
            end: x.end_at.iso8601,
            color: x.get_color,
            url: Rails.application.routes.url_helpers.client_service_path({client_id: x.client_id, id: x.id})
          } 
        end
    }.compact.flatten
  end

  def title_calendar
    # return "#{(self.client.nil? ? "" : self.client.company_name)}, #{(self.location.nil? ? "" : self.location.name)}, #{(self.brand_ambassador.nil? ? "-" : self.brand_ambassador.name)}"
    return "#{(self.client.nil? ? "" : self.client.company_name)}, #{(self.location.nil? ? "" : self.location.name)}, #{self.start_date_time}, #{(self.brand_ambassador.nil? ? "-" : self.brand_ambassador.name)}"
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
      "#8DB4E3"
    when 2
      "#92D050"
    when 3
      "#FFFF00"
    when 4
      "#0070C0"
    when 5
      "#A5A5A5"
    when 6
      "#FFC000"
    when 7
      "#00B050"
    when 8
      "#E46D0A"
    when 9
      "#FF0000"
    end
  end

  def client_and_companyname
    # "#{client.name}/#{client.company_name}"
    "#{client.company_name}"
  end

  def date
    start_at.strftime("%m/%d/%Y")
  end

  def complete_date_time
    "#{start_at.strftime("%m/%d/%Y")} - #{start_at.strftime("%I:%M %p")}/#{end_at.strftime("%I:%M %p")}"
  end

  def start_date_time
    "#{start_at.strftime("%I:%M %p")}"
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
    when 10
      "Invoiced"      
    end
  end

  def time_at
    "#{start_at.strftime("%I:%M%p")} - #{end_at.strftime("%I:%M%p")}"
  end

  def company_name
    client.nil? ? "" : client.company_name
  end

  def cancelled
    update_attribute(:status, Service.status_cancelled)
  end

  def ba_rate
    brand_ambassador.rate * TimeDifference.between(start_at, end_at).in_hours
  end

  def total_ba_paid
    ba_rate + (report.expense_one.nil? ? 0 : report.expense_one) + (brand_ambassador.mileage ? (report.travel_expense.nil? ? 0 : report.travel_expense) : 0)
  end  

  def can_modify?
    [Service.status_scheduled, Service.status_confirmed, Service.status_rejected,
      Service.status_unrespond].include?(status)
  end

  def can_reassign?
    self.status == Service.status_rejected || self.status == Service.status_unrespond || self.status == Service.status_scheduled || self.status == Service.status_confirmed
  end

  def can_rescheduled?
    self.status == Service.status_scheduled || self.status == Service.status_confirmed || self.status == Service.status_rejected
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
    [Service.status_conducted].include?(status)
  end

  def is_assigned?
    ![Service.status_rejected, Service.status_cancelled].include?(status)
  end

  def is_overlap?(interval_start_at, interval_end_at)
    (start_at.to_datetime - interval_end_at) * (interval_start_at - end_at.to_datetime) >= 0
  end

  def is_ba_active?
    brand_ambassador.is_active
  end

  def is_co_op?
    !co_op_client_id.nil?
  end  

  def set_data_true
    self.update_attribute(:is_active, true)
  end

  def set_data_false
    self.update_attribute(:is_active, false)
  end

  def grand_total
    expense = 0
    expense = report.expense_one.to_f + report.travel_expense.to_f unless report.nil?
    client.rate.to_f + expense
  end

  def export_data
    [
      location.name,
      client.company_name,
      brand_ambassador.name,
      start_at.strftime("%m/%d/%y"),
      report.total_units_sold,
      report.ave_product_price,
      report.traffic,
      start_at.strftime("%A"),
      start_at.strftime("%p"),
      report.product_one == "" ? "-" : report.product_one,
      report.product_two == "" ? "-" : report.product_two,
      report.product_three == "" ? "-" : report.product_three,
      report.product_four == "" ? "-" : report.product_four,
      report.product_five == "" ? "-" : report.product_five,
      report.product_six == "" ? "-" : report.product_six,
      report.product_one_sold.nil? ? "-" : report.product_one_sold,
      report.product_two_sold.nil? ? "-" : report.product_two_sold,
      report.product_three_sold.nil? ? "-" : report.product_three_sold,
      report.product_four_sold.nil? ? "-" : report.product_four_sold,
      report.product_five_sold.nil? ? "-" : report.product_five_sold,
      report.product_six_sold.nil? ? "-" : report.product_six_sold,
      report.est_customer_touched.blank? ? "-" : report.est_customer_touched
    ]

  end

end
