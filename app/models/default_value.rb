# == Schema Information
#
# Table name: default_values
#
#  id                :integer          not null, primary key
#  rate_project      :decimal(8, 2)
#  created_at        :datetime
#  updated_at        :datetime
#  traffic           :string(255)
#  sample_product    :string(255)
#  service_hours_est :integer
#  send_unrespond    :integer
#  co_op_price       :decimal(8, 2)
#

class DefaultValue < ActiveRecord::Base
  validates :rate_project, :service_hours_est, :send_unrespond, presence: true
  validates :rate_project, :service_hours_est, :send_unrespond, numericality: true  

  def self.rate_project
    DefaultValue.first.rate_project
  end

  def self.traffic
    DefaultValue.first.traffic.split(";")
  end

  def self.sample_product
    DefaultValue.first.sample_product.split(";")
  end  

  def self.service_hours_est
    DefaultValue.first.service_hours_est
  end  

  def self.send_unrespond
    DefaultValue.first.send_unrespond
  end    

  def self.co_op_price
    DefaultValue.first.co_op_price
  end
end
