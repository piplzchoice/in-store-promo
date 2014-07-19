# == Schema Information
#
# Table name: default_values
#
#  id             :integer          not null, primary key
#  rate_project   :decimal(8, 2)
#  created_at     :datetime
#  updated_at     :datetime
#  traffic        :string(255)
#  sample_product :string(255)
#

class DefaultValue < ActiveRecord::Base
  validates :rate_project, presence: true
  validates :rate_project, numericality: true  

  def self.rate_project
    DefaultValue.first.rate_project
  end

  def self.traffic
    DefaultValue.first.traffic.split(";")
  end

  def self.sample_product
    DefaultValue.first.sample_product.split(";")
  end  
end
