# == Schema Information
#
# Table name: clients
#
#  id                :integer          not null, primary key
#  user_id           :integer
#  company_name      :string(255)
#  title             :string(255)
#  first_name        :string(255)
#  last_name         :string(255)
#  phone             :string(255)
#  street_one        :string(255)
#  street_two        :string(255)
#  city              :string(255)
#  state             :string(255)
#  zipcode           :string(255)
#  country           :string(255)
#  billing_name      :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  account_id        :integer
#  is_active         :boolean          default(TRUE)
#  rate              :decimal(8, 2)
#  additional_emails :text
#

class Client < ActiveRecord::Base
  serialize :additional_emails, JSON
  belongs_to :user
  belongs_to :account, :class_name => "User", :foreign_key => :account_id
  accepts_nested_attributes_for :account, allow_destroy: true

  has_many :orders
  has_many :services
  has_many :invoices
  has_many :additional_personnels
  has_many :co_op_services, foreign_key: 'co_op_client_id', class_name: 'Service'
  has_many :products

  validates :company_name, :first_name, :last_name, :phone, presence: true

  default_scope { order("created_at ASC") }
  scope :with_status_active, -> { where(is_active: true) }

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

  def self.autocomplete_search(q)
    Client.with_status_active.where("first_name ILIKE ? OR last_name ILIKE ? OR company_name ILIKE ?", "%#{q}%", "%#{q}%", "%#{q}%")
  end

  def self.filter_and_order(is_active)
    Client.where(is_active: is_active)
  end

  def self.calendar_services(params)
    client = find(params["client_id"])
    calendars = client.services.where(["start_at >= ? and start_at <= ?", params["start"], params["end"]]).collect{|x|
      unless x.status == Service.status_conducted
        if x.is_ba_active? && x.status != 12
          self.calendar_obj(
            x.title_calendar,
            x.start_at.iso8601,
            x.end_at.iso8601,
            x.get_color,
            Rails.application.routes.url_helpers.client_service_path({client_id: params["client_id"], id: x.id})
          )
        end
      end
    }.uniq.compact

    service_tbs = client.services.where(status: 12)
    unless service_tbs.blank?
      service_tbs.each do |srv|
        calendars.push(
          self.calendar_obj(
            srv.title_calendar,
            DateTime.parse(srv.tbs_data["first_date"]["start_at"]).iso8601,
            DateTime.parse(srv.tbs_data["first_date"]["end_at"]).iso8601,
            srv.get_color,
            Rails.application.routes.url_helpers.client_service_path({client_id: params["client_id"], id: srv.id})
          )
        )
        calendars.push(
          self.calendar_obj(
            srv.title_calendar,
            DateTime.parse(srv.tbs_data["second_date"]["start_at"]).iso8601,
            DateTime.parse(srv.tbs_data["second_date"]["end_at"]).iso8601,
            srv.get_color,
            Rails.application.routes.url_helpers.client_service_path({client_id: params["client_id"], id: srv.id})
          )
        )
      end
    end

    # service_tbs = client.services.where(status: 12)
    # unless service_tbs.blank?
    #   service_tbs.each do |srv|
    #     calendars.push(
    #       self.calendar_obj(
    #         srv.title_calendar,
    #         DateTime.parse(srv.tbs_data["first_date"]["start_at"]).iso8601,
    #         DateTime.parse(srv.tbs_data["first_date"]["end_at"]).iso8601,
    #         srv.get_color,
    #         Rails.application.routes.url_helpers.client_service_path({client_id: params["client_id"], id: srv.id})
    #       )
    #     )
    #     calendars.push(
    #       self.calendar_obj(
    #         srv.title_calendar,
    #         DateTime.parse(srv.tbs_data["second_date"]["start_at"]).iso8601,
    #         DateTime.parse(srv.tbs_data["second_date"]["end_at"]).iso8601,
    #         srv.get_color,
    #         Rails.application.routes.url_helpers.client_service_path({client_id: params["client_id"], id: srv.id})
    #       )
    #     )
    #   end
    # end

    return calendars.uniq.compact
  end

  def self.calendar_obj(title, start_date, end_date, color, url)
    {
      title: title,
      start: start_date,
      end: end_date,
      color: color,
      url: url
    }
  end

  def self.calendar_obj(title, start_date, end_date, color, url)
    {
      title: title,
      start: start_date,
      end: end_date,
      color: color,
      url: url
    }
  end

  def email
    account.email
  end

  def name
    "#{first_name} #{last_name}"
  end

  def billing_address
    if street_one.empty? && city.empty? && state.empty? && zipcode.empty?
      email
    else
      "#{street_one} #{street_two} #{city} #{state} #{zipcode}"
    end
  end

  def fullprofile
    "#{company_name} - #{first_name} #{last_name}"
  end

  def billing_name
    if read_attribute(:billing_name).empty?
      # "#{first_name} #{last_name}"
      "-"
    else
      read_attribute(:billing_name)
    end
  end

  # def rate
  #   if read_attribute(:rate).nil?
  #     DefaultValue.rate_project
  #   else
  #     read_attribute(:rate)
  #   end
  # end

  def reset_password
    password = Devise.friendly_token.first(8)
    account.password = password
    account.password_confirmation = password
    return password
  end

  def set_data_true
    self.update_attribute(:is_active, true)
  end

  def set_data_false
    self.update_attribute(:is_active, false)
  end
end
