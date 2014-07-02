class Client < ActiveRecord::Base
  belongs_to :user
  belongs_to :account, :class_name => "User", :foreign_key => :account_id

  has_many :projects

  default_scope { order("created_at ASC") }

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
