# == Schema Information
#
# Table name: services
#
#  id                  :integer          not null, primary key
#  project_id          :integer
#  location_id         :integer
#  brand_ambassador_id :integer
#  user_id             :integer
#  created_at          :datetime
#  updated_at          :datetime
#

class Service < ActiveRecord::Base
  belongs_to :user
  belongs_to :brand_ambassador
  belongs_to :location
  belongs_to :project
end
