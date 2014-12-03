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
#

class Invoice < ActiveRecord::Base
  serialize :line_items, JSON
  belongs_to :client

  def self.new_data(client_id, service_ids, line_items, rate_total_all, expsense_total_all, travel_total_all, grand_total_all, grand_total)
    data = self.new
    data.client_id = client_id
    data.service_ids = service_ids
    data.line_items = line_items
    data.rate_total_all = rate_total_all
    data.expsense_total_all = expsense_total_all
    data.travel_total_all = travel_total_all
    data.grand_total_all = grand_total_all
    data.grand_total = grand_total
    data.due_date = 15.days.from_now
    data
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

  def update_data(invoice_params)
    invoice_params[:date_received] = Date.strptime(invoice_params[:date_received], '%m/%d/%Y') unless invoice_params[:date_received].blank?
    self.update_attributes(invoice_params)
  end  
end
