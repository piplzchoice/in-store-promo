class BrandAmbassador < ActiveRecord::Base
  belongs_to :user
  belongs_to :account, :class_name => "User", :foreign_key => :account_id
  
  has_many :services

  def email
    account.email
  end  
end
