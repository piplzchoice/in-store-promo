class User < ActiveRecord::Base
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :clients
  has_one :client, foreign_key: 'account_id', class_name: 'Client'

  has_many :brand_ambassadors
  has_one :brand_ambassador, foreign_key: 'account_id', class_name: 'BrandAmbassador'

  has_many :projects
  has_many :services

  default_scope { order("created_at ASC") }

  def self.all_ismp
    with_role(:ismp)
  end

  def save_ismp
    self.add_role :ismp
    self.save
  end
end
