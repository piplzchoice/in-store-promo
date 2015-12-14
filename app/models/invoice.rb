# == Schema Information
#
# Table name: invoices
#
#  id                 :integer          not null, primary key
#  client_id          :integer
#  service_ids        :string(255)
#  line_items         :text
#  created_at         :datetime
#  updated_at         :datetime
#  rate_total_all     :decimal(8, 2)
#  expsense_total_all :decimal(8, 2)
#  travel_total_all   :decimal(8, 2)
#  grand_total_all    :decimal(8, 2)
#  status             :integer          default(0)
#  grand_total        :decimal(8, 2)
#  due_date           :date
#  amount_received    :decimal(8, 2)
#  date_received      :date
#  number             :string(255)
#  issue_date         :date
#  terms              :string(255)
#  po                 :string(255)
#  file               :string(255)
#

class Invoice < ActiveRecord::Base
  include ApplicationHelper

  serialize :line_items, JSON
  serialize :data, JSON
  belongs_to :client
  mount_uploader :file, ImageUploader

  def self.options_select_terms
    [
      ["Due On Receipt"],
      ["Net 7"],
      ["Net 14"],
      ["Net 30"],
    ]
  end  

  def self.new_data(client_id, service_ids, line_items, rate_total_all, 
    expsense_total_all, travel_total_all, grand_total_all, grand_total, invoice_params)
    invoice = self.new
    invoice.client_id = client_id
    invoice.service_ids = service_ids
    invoice.line_items = line_items
    invoice.rate_total_all = rate_total_all
    invoice.expsense_total_all = expsense_total_all
    invoice.travel_total_all = travel_total_all
    invoice.grand_total_all = grand_total_all
    invoice.grand_total = grand_total    
    invoice.number = invoice_params[:invoice_number] 
    invoice.issue_date = Date.strptime(invoice_params[:invoice_date], '%m/%d/%Y')

    data = []
    service_ids.split(",").each do |service_id|
      service = Service.find(service_id)
      item = {
        service_id: service_id,
        demo_date: service.start_at.strftime('%m/%d/%Y'),
        start_time: service.start_at.strftime("%I:%M %p"),
        rate: ActionController::Base.helpers.number_to_currency((service.client.nil? ? "" : service.client.rate)),
        product_expenses: ActionController::Base.helpers.number_to_currency(service.report_service.expense_one),
        travel_expense: (service.brand_ambassador.mileage ? (service.report_service.travel_expense.nil? ? "-" : ActionController::Base.helpers.number_to_currency(service.report_service.travel_expense)) : "-"),
        amount: ActionController::Base.helpers.number_to_currency(service.grand_total)
      }

      data.push(item)
    end          
    
    invoice.data = data
    invoice.terms = invoice_params[:terms]
    case invoice.terms
    when "Net 7"
      days = 7.days
    when "Net 14"
      days = 14.days
    when "Net 30"
      days = 30.days
    else
      days = 0.days
    end

    invoice.due_date = invoice.issue_date.to_time + days
    invoice.po = invoice_params[:po]
    invoice
  end

  def self.filter_and_order(parameters)
    data = nil
    conditions = {}
    conditions.merge!(status: parameters["status"])

    if parameters["client_name"] != ""
      data = Invoice.joins(:client).where(clients: {id: parameters["client_name"]}).where(conditions)
    else
      data = Invoice.where(conditions)
    end

    data = data.order("#{parameters["sort_column"]} #{parameters["sort_direction"]}")

    return data
  end  

  def update_invoice(line_items, rate_total_all, 
    expsense_total_all, travel_total_all, grand_total_all, grand_total)
    self.line_items = line_items
    self.rate_total_all = rate_total_all
    self.expsense_total_all = expsense_total_all
    self.travel_total_all = travel_total_all
    self.grand_total_all = grand_total_all
    self.grand_total = grand_total    
    self.save
  end  

  def list_email
    client.additional_emails
  end

  def update_data(invoice_params)
    invoice_params[:date_received] = Date.strptime(invoice_params[:date_received], '%m/%d/%Y') unless invoice_params[:date_received].blank?
    self.update_attributes(invoice_params)
  end  

  def is_paid_match?
    if amount_received.nil?
      true
    else
      grand_total_all == amount_received    
    end    
  end
end
