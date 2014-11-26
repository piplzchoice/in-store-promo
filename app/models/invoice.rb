# == Schema Information
#
# Table name: invoices
#
#  id          :integer          not null, primary key
#  client_id   :integer
#  service_ids :string(255)
#  line_items  :text
#  created_at  :datetime
#  updated_at  :datetime
#

class Invoice < ActiveRecord::Base
  serialize :line_items, JSON

  def self.new_data(client_id, service_ids, line_items)
    data = self.new
    data.client_id = client_id
    data.service_ids = service_ids
    data.line_items = line_items
    data
  end
end
