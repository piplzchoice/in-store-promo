# == Schema Information
#
# Table name: services
#
#  id                    :integer          not null, primary key
#  project_id            :integer
#  location_id           :integer
#  brand_ambassador_id   :integer
#  created_at            :datetime
#  updated_at            :datetime
#  start_at              :datetime
#  end_at                :datetime
#  details               :text
#  status                :integer          default(1)
#  token                 :string(255)
#  is_active             :boolean          default(TRUE)
#  client_id             :integer
#  co_op_client_id       :integer
#  alert_sent            :boolean          default(FALSE)
#  alert_sent_date       :datetime
#  alert_sent_admin      :boolean          default(FALSE)
#  alert_sent_admin_date :datetime
#  parent_id             :integer
#  is_old_service        :boolean          default(TRUE)
#  inventory_confirm     :boolean          default(FALSE)
#  inventory_date        :date
#  inventory_confirmed   :string(255)
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
# 10. Invoiced --> "#0070C0"
# 11. Inventory Confirmed ---> "#ccffcc" / "#b6fcc2"

class Service < ActiveRecord::Base

  belongs_to :client
  belongs_to :project
  belongs_to :brand_ambassador
  belongs_to :location
  
  has_one :report
  has_many :co_op_services, foreign_key: 'parent_id', class_name: 'Service'
  has_and_belongs_to_many :products

  belongs_to :parent, :class_name => "Service", foreign_key: 'parent_id'

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
    if parameters["status"] != ""
      conditions.merge!(status: parameters["status"]) 
    else
      if parameters["is_client"]
        conditions.merge!(status: [2,6,7,10]) 
      end
    end

    conditions.merge!(brand_ambassador_id: parameters["assigned_to"]) if parameters["assigned_to"] != ""

    unless parameters["location_name"].nil?
      conditions.merge!(location_id: parameters["location_name"]) if parameters["location_name"] != ""
    end

    if parameters["client_name"] != ""
      data = Service.joins(:client).where(clients: {id: parameters["client_name"]}).where(conditions)
    else
      data = Service.joins(:client).where(clients: {is_active: true}).where(conditions)
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

  def self.status_inventory_confirmed
    return 11
  end  

  def self.send_notif_after
    return 2.round
  end

  def self.build_data(service_params)
    # service_params[:co_op_client_id] = nil unless co_op_price_box
    service_params[:product_ids] = JSON.parse(service_params[:product_ids])
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

  def self.calculate_total_rate(service_ids)
    total_paid = 0
    Service.find(service_ids).each do |service|
      total_paid += service.ba_rate.to_f
    end
    return total_paid
  end

  def self.calculate_total_expense(service_ids)
    total_paid = 0
    Service.find(service_ids).each do |service|
      total_paid += service.report_service.expense_one.nil? ? 0 : service.report_service.expense_one.to_f
    end
    return total_paid
  end

  def self.calculate_total_travel_expense(service_ids)
    total_paid = 0
    Service.find(service_ids).each do |service|
      total_paid += (service.brand_ambassador.mileage ? (service.report_service.travel_expense.nil? ? 0 : service.report_service.travel_expense.to_f) : 0)
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
      ["Inventory", Service.status_inventory_confirmed],
      ["Reported", Service.status_reported],
      ["Invoiced", Service.status_invoiced],      
      ["Paid", Service.status_paid],
      ["BA paid", Service.status_ba_paid],
      ["Cancelled", Service.status_cancelled]
    ]
  end

  def self.options_select_status_client
    [
      ["All", ""],
      ["BA Confirmed", Service.status_confirmed],
      ["Reported", Service.status_reported],
      ["Invoiced", Service.status_invoiced],
      ["Paid", Service.status_paid],
    ]
  end

  def self.calendar_services(status, assigned_to, client_name, sort_column, sort_direction, is_client = false)
    data = {
      "status" => status, 
      "assigned_to" => assigned_to, 
      "client_name" => client_name, 
      "sort_column" => sort_column, 
      "sort_direction" => sort_direction,
      "is_client" => is_client
    }
    Service.filter_and_order(data).collect{|x|
      unless x.status == Service.status_conducted
        # if x.status != Service.status_cancelled
          {
            title: x.title_calendar,
            start: x.start_at.iso8601,
            end: x.end_at.iso8601,
            color: x.get_color,
            url: Rails.application.routes.url_helpers.client_service_path({client_id: x.client_id, id: x.id})
          } 
        # end
      end
    }.compact.flatten
  end

  def self.check_inventory_confirmation
    
  end

  def report_service    
    if !report.nil?
      if !parent.nil?
        if report.is_old_report
          parent.report
        else
          report
        end
      else
        report
      end
    else
      nil
    end
  end  

  def coop_service_report_data
    if !parent.nil?
      parent.report
    else
      report
    end
  end

  def title_calendar
    # return "#{(self.client.nil? ? "" : self.client.company_name)}, #{(self.location.nil? ? "" : self.location.name)}, #{(self.brand_ambassador.nil? ? "-" : self.brand_ambassador.name)}"
    return "#{(self.client.nil? ? "" : self.client.company_name)}, #{(self.location.nil? ? "" : self.location.name)}, #{self.start_date_time}, #{(self.brand_ambassador.nil? ? "-" : self.brand_ambassador.name)}"
  end

  def update_data(service_params)
    service_params[:product_ids] = JSON.parse(service_params[:product_ids])
    service_params[:start_at] = DateTime.strptime(service_params[:start_at], '%m/%d/%Y %I:%M %p') unless service_params[:start_at].blank?
    service_params[:end_at] = DateTime.strptime(service_params[:end_at], '%m/%d/%Y %I:%M %p')  unless service_params[:end_at].blank?
    self.update_attributes(service_params)

    if self.is_co_op?
      service_params.delete(:brand_ambassador_id)

      self.co_op_services.each do |srv|
        service_params[:brand_ambassador_id] = srv.brand_ambassador_id
        srv.update_attributes(service_params)
      end
    else
      true
    end
  end

  def update_inventory(service_params)
    service_params[:product_ids] = JSON.parse(service_params[:product_ids])
    service_params[:inventory_date] = DateTime.strptime(service_params[:inventory_date], '%m/%d/%Y')
    self.update_attributes(service_params)

    if self.is_co_op?
      if self.co_op_services.empty?
        self.parent.update_attributes(service_params)
      else
        self.co_op_services.each do |srv|
          srv.update_attributes(service_params)
        end        
      end
    else
      true
    end    
  end

  def check_data_changes(service_params)
    service_params[:start_at] = DateTime.strptime(service_params[:start_at], '%m/%d/%Y %I:%M %p') unless service_params[:start_at].blank?
    service_params[:end_at] = DateTime.strptime(service_params[:end_at], '%m/%d/%Y %I:%M %p')  unless service_params[:end_at].blank?
    
    self.location_id = service_params[:location_id]
    self.brand_ambassador_id = service_params[:brand_ambassador_id]
    self.start_at = service_params[:start_at]
    self.end_at =service_params[:end_at]
    self.details = service_params[:details]

    # self.co_op_client_id = service_params[:co_op_client_id]
    self.parent = service_params[:parent]

    self.changes.size == 1 && !self.changes["details"].nil?
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
      "#000000"
    when 10
      "#0070C0"
    when 11
      "#b6fcc2" #"#ccffcc" 
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
    when 11
      "Inventory"
    end
  end

  def time_at
    "#{start_at.strftime("%I:%M%p")} - #{end_at.strftime("%I:%M%p")}"
  end

  def company_name
    client.nil? ? "" : client.company_name
  end

  def cancelled
    self.update_attributes({status: Service.status_cancelled})
    
    if is_co_op?
      if self.co_op_services.empty?
        self.parent.update_attributes({status: Service.status_cancelled})
      else
        self.co_op_services.each do |service_coop|
          service_coop.update_attributes({status: Service.status_cancelled})
        end
      end
    end    
  end

  def ba_rate
    brand_ambassador.rate * TimeDifference.between(start_at, end_at).in_hours
  end

  def total_ba_paid
    ba_rate + (report_service.expense_one.nil? ? 0 : report_service.expense_one) + (brand_ambassador.mileage ? (report_service.travel_expense.nil? ? 0 : report_service.travel_expense) : 0)
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

  # def is_co_op?
  #   !co_op_client_id.nil?
  # end  

  def set_data_true
    self.update_attribute(:is_active, true)
  end

  def set_data_false
    self.update_attribute(:is_active, false)
  end

  def grand_total
    expense = 0
    expense = report_service.expense_one.to_f + report_service.travel_expense.to_f unless report_service.nil?
    client.rate.to_f + expense
  end

  def export_data
    products = []
    if report_service.client_products.nil?
      products = [
        report_service.product_one == "" ? "-" : report_service.product_one.to_f,
        report_service.product_two == "" ? "-" : report_service.product_two.to_f,
        report_service.product_three == "" ? "-" : report_service.product_three.to_f,
        report_service.product_four == "" ? "-" : report_service.product_four.to_f,
        report_service.product_five == "" ? "-" : report_service.product_five.to_f,
        report_service.product_six == "" ? "-" : report_service.product_six.to_f,
        "-",
        "-",
        "-",
        "-",
        "-",
        "-",
        "-",
        "-",
        "-",      
        report_service.product_one_sold.nil? ? "-" : report_service.product_one_sold.to_f,
        report_service.product_two_sold.nil? ? "-" : report_service.product_two_sold.to_f,
        report_service.product_three_sold.nil? ? "-" : report_service.product_three_sold.to_f,
        report_service.product_four_sold.nil? ? "-" : report_service.product_four_sold.to_f,
        report_service.product_five_sold.nil? ? "-" : report_service.product_five_sold.to_f,
        report_service.product_six_sold.nil? ? "-" : report_service.product_six_sold.to_f,
        "-",
        "-",
        "-",
        "-",
        "-",
        "-",
        "-",
        "-",
        "-",
        report_service.est_customer_touched.blank? ? "-" : report_service.est_customer_touched.to_f
      ]
    else
      unfill_product = 15 - report_service.client_products.size
      report_service.client_products.each_with_index do |product, i|
        products.push(product["name"])
      end

      unfill_product.times{|x| products.push("-")} unless unfill_product == 0

      report_service.client_products.each_with_index do |product, i|
        products.push(product["sold"].to_f)
      end

      unfill_product.times{|x| products.push("-")} unless unfill_product == 0      
      products.push(report_service.est_customer_touched.blank? ? "-" : report_service.est_customer_touched.to_f)
    end

    value_row = [
      location.name,
      client.company_name,
      brand_ambassador.name,
      start_at.strftime("%m/%d/%y"),
      report_service.total_units_sold.to_f,
      report_service.ave_product_price.to_f,
      report_service.traffic,
      start_at.strftime("%A"),
      start_at.strftime("%p"),      
    ].push(products).flatten!

    return value_row
    
  end

  def create_coops(co_op_client_id)
    coop = self.co_op_services.build
    
    coop.location = self.location
    # coop.brand_ambassador_id = self.brand_ambassador_id
    coop.brand_ambassador = BrandAmbassador.find_by_name("Admin")
    coop.start_at = self.start_at
    coop.end_at =  self.end_at
    coop.details = self.details
    coop.status = self.status
    coop.is_active = self.is_active
    coop.client_id = co_op_client_id
    coop.product_ids = self.product_ids
    coop.is_old_service = false
    coop.save!
  end

  def is_co_op?
    !parent.nil? || !co_op_services.empty?
  end

  def update_status_to_confirmed(token)
    self.update_attributes({status: Service.status_confirmed, token: token})
    unless self.co_op_services.empty?
      self.co_op_services.each do |service_coop|
        service_coop.update_attributes({status: Service.status_confirmed, token: token})
      end
    end
  end

  def update_status_to_rejected(token)
    self.update_attributes({status: Service.status_rejected, token: token})
    unless self.co_op_services.empty?
      self.co_op_services.each do |service_coop|
        service_coop.update_attributes({status: Service.status_rejected, token: token})
      end
    end    
  end

  def update_status_to_reported
    self.update_attributes({status: Service.status_reported})
    unless self.co_op_services.empty?
      self.co_op_services.each do |service_coop|
        service_coop.update_attributes({status: Service.status_reported})
      end
    end    
  end


  def update_status_to_conducted
    self.update_attributes({status: Service.status_conducted})
    
    if is_co_op?
      if self.co_op_services.empty?
        self.parent.update_attributes({status: Service.status_conducted})
      else
        self.co_op_services.each do |service_coop|
          service_coop.update_attributes({status: Service.status_conducted})
        end
      end
    end    
  end

  def update_status_after_reported(status)
    self.update_attributes({status: status})
    
    if is_co_op?
      if self.co_op_services.empty?
        self.parent.update_attributes({status: status})
      else
        self.co_op_services.each do |service_coop|
          service_coop.update_attributes({status: status})
        end
      end
    end        
  end

  def update_status_scheduled    
    self.update_attributes({status: Service.status_scheduled})
    
    if is_co_op?
      if self.co_op_services.empty?
        self.parent.update_attributes({status: Service.status_scheduled})
      else
        self.co_op_services.each do |service_coop|
          service_coop.update_attributes({status: Service.status_scheduled})
        end
      end
    end            
  end


  def update_status_inventory_confirmed
    self.update_attributes({status: Service.status_inventory_confirmed})
    
    if is_co_op?
      if self.co_op_services.empty?
        self.parent.update_attributes({status: Service.status_inventory_confirmed})
      else
        self.co_op_services.each do |service_coop|
          service_coop.update_attributes({status: Service.status_inventory_confirmed})
        end
      end
    end            
  end

end
