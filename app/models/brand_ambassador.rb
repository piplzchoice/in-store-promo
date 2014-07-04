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
  accepts_nested_attributes_for :account, allow_destroy: true

  validates :name, :phone, :address, :grade, :rate, :mileage, presence: true
  validates :grade, :rate, numericality: true
  
  has_many :services

  def self.new_with_account(brand_ambassador_params, user_id)
    brand_ambassador = self.new(brand_ambassador_params)
    brand_ambassador.user_id = user_id
    brand_ambassador.build_account(brand_ambassador_params["account_attributes"])
    password =  Devise.friendly_token.first(8)
    brand_ambassador.account.password = password
    brand_ambassador.account.password_confirmation = password
    brand_ambassador.account.add_role :ba   
    return brand_ambassador, password
  end

  def email
    account.email
  end  

  def mileage_choice
    (mileage ? "Yes" : "No")
  end
end
