# == Schema Information
#
# Table name: orders
#
#  id                 :integer          not null, primary key
#  client_id          :integer
#  number             :string(255)
#  status             :integer          default(0)
#  created_at         :datetime
#  updated_at         :datetime
#  service_copy       :text
#  dot_number         :string(255)
#  product_sample     :string(255)
#  to_be_completed_by :string(255)
#  distributor        :string(255)
#  comments           :text
#

class Order < ActiveRecord::Base

  enum status: [
    :open,
    :closed
  ]

  has_many :services
  has_and_belongs_to_many :locations
  has_and_belongs_to_many :products

  belongs_to :client

  serialize :service_copy, JSON

  def generate_number(client_id)
    client = Client.find client_id
    order_size = client.orders.size
    company_name = client.company_name.split.map(&:first).join.upcase
    # "ORD-#{company_name}-%05d" % (order_size == 1 ? 1 : order_size + 1)
    "ORD-#{company_name}-%05d" % (order_size + 1)
  end

  def recurring
    rec_order = Order.new({
      status: 0,
      client_id: self.client.id,
      location_ids: self.location_ids,
      product_ids: self.product_ids
    })

    rec_order.number = rec_order.generate_number(self.client.id)
    rec_order.service_copy = []
    self.services.each_with_index do |service, index|
      rec_order.service_copy << {
        location_id: service.location_id,
        brand_ambassador_ids: [],
        first_date: {start_at: nil, end_at: nil},
        second_date: {start_at: nil, end_at: nil},
        status: 0,
        index: index
      }
    end

    rec_order.save
    return rec_order
  end
end
