# == Schema Information
#
# Table name: clients
#
#  id           :integer          not null, primary key
#  user_id      :integer
#  company_name :string(255)
#  title        :string(255)
#  first_name   :string(255)
#  last_name    :string(255)
#  phone        :string(255)
#  street_one   :string(255)
#  street_two   :string(255)
#  city         :string(255)
#  state        :string(255)
#  zipcode      :string(255)
#  country      :string(255)
#  billing_name :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#  account_id   :integer
#  is_active    :boolean          default(TRUE)
#  rate         :decimal(8, 2)
#

class Client < ActiveRecord::Base
  belongs_to :user
  belongs_to :account, :class_name => "User", :foreign_key => :account_id
  accepts_nested_attributes_for :account, allow_destroy: true

  has_many :services
  has_many :co_op_services, foreign_key: 'co_op_client_id', class_name: 'Service'

  validates :company_name, :first_name, :last_name, :phone, presence: true

  default_scope { order("created_at ASC") }
  scope :with_status_active, -> { where(is_active: true) }

  def self.new_with_account(client_params, user_id)
    client = self.new(client_params)
    client.user_id = user_id
    client.build_account(client_params["account_attributes"])
    password =  Devise.friendly_token.first(8)
    client.account.password = password
    client.account.password_confirmation = password
    client.account.add_role :client   
    return client, password
  end

  def self.autocomplete_search(q)
    Client.with_status_active.where("first_name ILIKE ? OR last_name ILIKE ? OR company_name ILIKE ?", "%#{q}%", "%#{q}%", "%#{q}%")    
  end

  def self.filter_and_order(is_active)
    Client.where(is_active: is_active)
  end  

  def self.calendar_services(client_id)
    client = find(client_id)
    client.services.collect{|x|       
      {
        title: x.title_calendar,
        start: x.start_at.iso8601,
        end: x.end_at.iso8601,
        color: x.get_color,
        url: Rails.application.routes.url_helpers.client_service_path({client_id: client_id, id: x.id})
      } if x.is_ba_active?
    }.uniq.compact
  end  

  def email
    account.email
  end

  def name
    "#{first_name} #{last_name}"
  end

  def billing_address
    "#{street_one} #{street_two} #{city} #{state} #{zipcode} #{country}"
  end

  def fullprofile
    "#{company_name} - #{first_name} #{last_name}"
  end

  def reset_password
    password = Devise.friendly_token.first(8)
    account.password = password
    account.password_confirmation = password
    return password    
  end

  def set_data_true
    self.update_attribute(:is_active, true)
  end

  def set_data_false
    self.update_attribute(:is_active, false)
  end  
end
