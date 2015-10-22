# == Schema Information
#
# Table name: products
#
#  id         :integer          not null, primary key
#  client_id  :integer
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Product < ActiveRecord::Base
  belongs_to :client
  has_and_belongs_to_many :services
end
