class Service < ActiveRecord::Base
  belongs_to :user
  belongs_to :brand_ambassador
  belongs_to :location
  belongs_to :project
end
