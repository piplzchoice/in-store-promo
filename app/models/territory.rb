# == Schema Information
#
# Table name: territories
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Territory < ActiveRecord::Base
  has_many :locations
  has_and_belongs_to_many :brand_ambassadors
end
