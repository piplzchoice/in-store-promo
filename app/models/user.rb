class User < ActiveRecord::Base
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :clients
  has_many :brand_ambassadors
  has_many :projects
  has_many :services

  def self.all_ismp
    with_role(:ismp)
  end

  def save_ismp
    self.add_role :ismp
    self.save
  end
end
