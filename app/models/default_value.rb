# == Schema Information
#
# Table name: default_values
#
#  id           :integer          not null, primary key
#  rate_project :decimal(8, 2)
#  created_at   :datetime
#  updated_at   :datetime
#

class DefaultValue < ActiveRecord::Base
  validates :rate_project, presence: true
  validates :rate_project, numericality: true  

  def self.rate_project
    DefaultValue.first.rate_project
  end
end