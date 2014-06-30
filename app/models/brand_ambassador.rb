class BrandAmbassador < ActiveRecord::Base
  belongs_to :user
  has_many :services
end
