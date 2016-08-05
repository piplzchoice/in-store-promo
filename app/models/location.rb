# == Schema Information
#
# Table name: locations
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  address       :string(255)
#  city          :string(255)
#  state         :string(255)
#  zipcode       :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  user_id       :integer
#  is_active     :boolean          default(TRUE)
#  contact       :string(255)
#  phone         :string(255)
#  email         :string(255)
#  notes         :text
#  territory_id  :integer
#  more_contacts :text
#

class Location < ActiveRecord::Base
  belongs_to :user
  has_many :services
  belongs_to :territory
  has_and_belongs_to_many :brand_ambassadors
  has_and_belongs_to_many :orders

  serialize :more_contacts, JSON

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

  def self.import_location_excel(file)
    count_success = 0
    count_duplicate = 0
    spreadsheet = open_spreadsheet(file)
    spreadsheet.count.times do |row|
      line = row + 1
      unless line == 1
        location = Location.new
        location.name = spreadsheet.cell(line, 1).to_s
        location.address = spreadsheet.cell(line, 2).to_s
        location.city = spreadsheet.cell(line, 3).to_s
        location.state = spreadsheet.cell(line, 4).to_s
        location.zipcode = spreadsheet.cell(line, 5).to_s
        location.more_contacts = {
          contact_1_name: spreadsheet.cell(line, 6).to_s,
          contact_1_departement: spreadsheet.cell(line, 7).to_s,
          contact_1_phone: spreadsheet.cell(line, 8).to_s,
          contact_1_email: spreadsheet.cell(line, 9).to_s,
          contact_2_name: spreadsheet.cell(line, 10).to_s,
          contact_2_departement: spreadsheet.cell(line, 11).to_s,
          contact_2_phone: spreadsheet.cell(line, 12).to_s,
          contact_2_email: spreadsheet.cell(line, 13).to_s
        }

        if Location.where(name: location.name, address: location.address, city: location.city, state: location.state, zipcode: location.zipcode).empty?
          count_success = count_success + 1
          location.save
        else
          count_duplicate = count_duplicate + 1
        end
      end
    end

    return "Successfully import #{count_success} new locations and not import #{count_duplicate}, duplicate data"
  end

  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
    when ".xls" then Roo::Spreadsheet.open(file.path, extension: :xls)
    when ".xlsx" then Roo::Spreadsheet.open(file.path, extension: :xlsx)
    else raise "Please upload only file with ext .xls or .xlsx"
    end
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
