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
#

class Client < ActiveRecord::Base
  belongs_to :user
  belongs_to :account, :class_name => "User", :foreign_key => :account_id
  accepts_nested_attributes_for :account

  has_many :projects  

  default_scope { order("created_at ASC") }

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

  def email
    account.email
  end

  def name
    "#{first_name} #{last_name}"
  end

  def billing_address
    "#{street_one} #{street_two} #{city} #{state} #{zipcode} #{country}"
  end
end
