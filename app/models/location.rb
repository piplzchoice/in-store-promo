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
  has_and_belongs_to_many :orders

  validates :name, :address, :city, :state, :zipcode, presence: true
  scope :with_status_active, -> { where(is_active: true) }
  # default_scope { order("created_at ASC") }

  def self.filter_and_order(params)
    hash = {is_active: params["is_active"]}
    location_name = params["location_name"]
    is_location_name_string = false
    locations = nil

    if location_name != "" && location_name.to_i != 0
      hash.merge!({id: location_name})
    else
      is_location_name_string = true
    end

    if is_location_name_string
      locations = Location.where(hash).where("name ILIKE ?", "%#{location_name}%")
    else
      locations = Location.where(hash)
    end

    if params["city"] != ""
      locations = locations.where("city ILIKE ?", "%#{params["city"]}%")
    end

    return locations.order("#{params["sort_column"]} #{params["sort_direction"]}")

  end

  def self.autocomplete_search(q)
    Location.with_status_active.where("name ILIKE ?", "%#{q}%")
  end

  def self.complete_location
    "#{name} - #{address}, #{city}"
  end

  def complete_location
    "#{name} - #{address}, #{city}"
  end

  def new_complete_location
    "#{name} - #{address}, #{city}"
  end

  def set_data_true
    self.update_attribute(:is_active, true)
  end

  def set_data_false
    self.update_attribute(:is_active, false)
  end

  def export_data
    data_field = [
      name,
      address,
      city,
      zipcode,
      contact,
      phone,
      email,
      notes
    ]

    brand_ambassadors.with_status_active.each do |ba|
      data_field << ba.name_split
    end

    return data_field

  end
end
