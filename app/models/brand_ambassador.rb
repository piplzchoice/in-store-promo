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
#  created_at :datetime
#  updated_at :datetime
#  account_id :integer
#  mileage    :boolean
#  rate       :decimal(8, 2)
#

class BrandAmbassador < ActiveRecord::Base
  belongs_to :user
  belongs_to :account, :class_name => "User", :foreign_key => :account_id
  accepts_nested_attributes_for :account, allow_destroy: true

  validates :name, :phone, :address, :grade, :rate, presence: true
  validates :grade, :rate, numericality: true
  
  has_many :services
  has_many :available_dates

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

  def self.get_available_people(datetime)
    time = DateTime.strptime(datetime, '%m/%d/%Y %I:%M %p')
    time_range = time.midnight..(time.midnight + 1.day)

    ba_data = BrandAmbassador.joins(:available_dates).where(available_dates: {availablty: time})
    ba_data.collect{|x| x if x.services.where({start_at: time_range}).blank?}.compact    
  end

  def email
    account.email
  end  

  def mileage_choice
    (mileage ? "Yes" : "No")
  end

  def reset_password
    password = Devise.friendly_token.first(8)
    account.password = password
    account.password_confirmation = password
    return password    
  end

  def available_calendar
    available_dates.collect{|x| {title: "", 
      start: x.availablty.strftime("%Y-%m-%d"), url: Rails.application.routes.url_helpers.available_date_path(x.id) } }
  end

  def disable_dates
    available_dates.all.collect{|x| x.availablty.strftime("%m/%d/%Y")}.to_json
  end
end
