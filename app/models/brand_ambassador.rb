# == Schema Information
#
# Table name: brand_ambassadors
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  name       :string(255)
#  phone      :string(255)
#  address    :string(255)
#  grade      :integer
#  rate       :decimal(5, 2)
#  created_at :datetime
#  updated_at :datetime
#  account_id :integer
#  mileage    :boolean
#

class BrandAmbassador < ActiveRecord::Base
  belongs_to :user
  belongs_to :account, :class_name => "User", :foreign_key => :account_id
  
  has_many :services

  def email
    account.email
  end  
end
