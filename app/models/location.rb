# == Schema Information
#
# Table name: locations
#
#  id           :integer          not null, primary key
#  name         :string(255)
#  address      :string(255)
#  city         :string(255)
#  state        :string(255)
#  zipcode      :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#  user_id      :integer
#  is_active    :boolean          default(TRUE)
#  contact      :string(255)
#  phone        :string(255)
#  email        :string(255)
#  notes        :text
#  territory_id :integer
#

class Location < ActiveRecord::Base
  belongs_to :user
  belongs_to :location
  belongs_to :territory
  has_and_belongs_to_many :brand_ambassadors

  validates :name, :address, :city, :state, :zipcode, presence: true
  scope :with_status_active, -> { where(is_active: true) }
  default_scope { order("created_at ASC") }

  def self.filter_and_order(is_active, name)
    Location.where(is_active: is_active).where("name ILIKE ?", "%#{name}%")
  end  

  def self.autocomplete_search(q)
    Location.where({is_active: true}).where("name ILIKE ?", "%#{q}%")
  end  

  def self.complete_location
    "#{name} - #{address}, #{city}"
  end

  def complete_location
    "#{name} - #{address}, #{city}"
  end  

  def set_data_true
    self.update_attribute(:is_active, true)
  end

  def set_data_false
    self.update_attribute(:is_active, false)
  end  

  def export_data
    [
      name,
      address,
      city,
      state,
      zipcode,
      contact,
      phone,
      email,
      notes
    ]    
  end
end
