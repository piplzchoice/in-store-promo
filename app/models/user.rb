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
#  is_active              :boolean          default(TRUE)
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
  has_many :locations

  default_scope { order("created_at ASC") }

  def self.all_ismp
    with_role(:ismp)
  end

  def save_ismp
    self.add_role :ismp
    self.save
  end

  def update_data(user_params)
    if user_params["password"].blank?
      user_params.delete("password")
      user_params.delete("password_confirmation")
    end
    self.update_attributes(user_params)
  end

  def update_ismp(user_params)
    if user_params["password"].blank?
      user_params.delete("password")
      user_params.delete("password_confirmation")
    end
    self.update_attributes(user_params)
  end

  def is_not_active?
    resp = false
    if self.has_role?(:ba)
      unless self.brand_ambassador.is_active
        resp = true
      end
    end
    resp
  end

  def set_data_true
    self.update_attribute(:is_active, true)
  end

  def set_data_false
    self.update_attribute(:is_active, false)
  end
end
