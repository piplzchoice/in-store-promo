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
#

class Invoice < ActiveRecord::Base
  serialize :line_items, JSON

  def self.new_data(client_id, service_ids, line_items, rate_total_all, expsense_total_all, travel_total_all, grand_total_all)
    data = self.new
    data.client_id = client_id
    data.service_ids = service_ids
    data.line_items = line_items
    data.rate_total_all = rate_total_all
    data.expsense_total_all = expsense_total_all
    data.travel_total_all = travel_total_all
    data.grand_total_all = grand_total_all
    data
  end
end
