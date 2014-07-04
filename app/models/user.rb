# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#

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
