# == Schema Information
#
# Table name: brand_ambassadors
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  name       :string(255)
#  phone      :string(255)
#  address    :string(255)
#  grade      :integer
#  created_at :datetime
#  updated_at :datetime
#  account_id :integer
#  mileage    :boolean
#  rate       :decimal(8, 2)
#  is_active  :boolean          default(TRUE)
#

class BrandAmbassador < ActiveRecord::Base
  belongs_to :user
  belongs_to :account, :class_name => "User", :foreign_key => :account_id
  accepts_nested_attributes_for :account, allow_destroy: true

  validates :name, :phone, :address, :grade, :rate, presence: true
  validates :grade, :rate, numericality: true
  
  has_many :services
  has_many :available_dates

  def self.new_with_account(brand_ambassador_params, user_id)
    brand_ambassador = self.new(brand_ambassador_params)
    brand_ambassador.user_id = user_id
    brand_ambassador.build_account(brand_ambassador_params["account_attributes"])
    password =  Devise.friendly_token.first(8)
    brand_ambassador.account.password = password
    brand_ambassador.account.password_confirmation = password
    brand_ambassador.account.add_role :ba   
    return brand_ambassador, password
  end

  def self.get_available_people(datetime)
    time = DateTime.strptime(datetime, '%m/%d/%Y %I:%M %p')
    time_range = time.midnight..(time.midnight + 1.day)

    ba_data = BrandAmbassador.joins(:available_dates).where(is_active: true, available_dates: {availablty: time})
    
    ba_data.collect{|ba|
      services = ba.services.where({start_at: time_range})
      available_date = ba.available_dates.where({availablty: time}).first

      if services.blank?
        if time.strftime("%p") == "AM"
          ba if available_date.am
        elsif time.strftime("%p") == "PM"
          # ba if available_date.pm
          ba if available_date.am || available_date.pm
        end
      else
        service = services.first     
        if service.status == Service.status_cancelled  
          ba if available_date.am || available_date.pm
        else
          unless time.strftime("%p") == service.start_at.strftime("%p")          
            if time.strftime("%p") == "AM"
              ba if available_date.am
            elsif time.strftime("%p") == "PM"
              ba if available_date.am || available_date.pm
            end            
          end          
        end
      end

    }.compact.flatten
  end

  def email
    account.email
  end  

  def mileage_choice
    (mileage ? "Yes" : "No")
  end

  def reset_password
    password = Devise.friendly_token.first(8)
    account.password = password
    account.password_confirmation = password
    return password    
  end

  def available_calendar
    available_dates.collect{|x| {title: "", 
      start: x.availablty.strftime("%Y-%m-%d") } }
  end

  def disable_dates
    available_dates.all.collect{|x| x.availablty.strftime("%m/%d/%Y")}.to_json
  end

  def get_monthly_date(date)
    available_dates.where(availablty: Date.new(date[:year].to_i, date[:month].to_i).beginning_of_month..Date.new(date[:year].to_i, date[:month].to_i).end_of_month)
  end

  def get_assignments
    services.collect{|x|
      if x.status == 2 || x.status == 4
        {
          title: x.title_calendar, 
          start: x.start_at.iso8601, 
          end: x.end_at.iso8601,
          color: x.get_color,
          url: Rails.application.routes.url_helpers.assignment_path({id: x.id})
        }
      end
    }.compact  
  end

  def self.get_all_available_dates 
    # "#3c763d" => green    
    # "#428bca" => blue
    # "#f0ad4e" => yellow

    dates = []
    self.all.each do |ba|
      ba.available_dates.each do |available_date| 
        time_range = available_date.availablty.midnight..(available_date.availablty.midnight + 1.day)
        services = ba.services.where({start_at: time_range})

        show = true
        if services.blank?
          if available_date.am
            color = "#3c763d"
          elsif !available_date.am && available_date.pm
            color = "#f0ad4e"
          end          
        else
          periods = services.collect{|x| x.start_at.strftime("%p") }
          if periods.size == 2
            show = false
          else
            if services.first.status != Service.status_rejected
              if periods.include?("AM")
                color = "#428bca"
              elsif periods.include?("PM")            

                # AM service can only be scheduled to start at 10 am or 11 am. 
                # If a service is scheduled for any of these times, and the BA was available for the whole day, 
                # please change the green color to blue color. That means that BA can complete the 
                # 1st service by as late as 3 pm and still have an opportunity to work another service.

                # If BA is available for whole day and scheduled for service starting at 12 pm or later, 
                # please change the color from green to none (not available) because this BA cannot be scheduled 
                # for a service during this day.
                #
                # If BA is available for whole day and scheduled for service starting at 3 PM or later, 
                # please change the color from green to orange because this BA has an opportunity 
                # to work on a morning service.                

                if available_date.am
                  service = services.first
                  if [12, 1, 2].include?(service.start_at.strftime("%I").to_i)
                    show = false
                  else
                    color = "#f0ad4e"
                  end
                else
                  show = false
                end

              end                        
            else
              show = false                      
            end          
          end          
        end

        if show
          hash = {
            title: ba.name,
            start: available_date.availablty.strftime("%Y-%m-%d"),
            url: Rails.application.routes.url_helpers.brand_ambassador_path(ba),
            color: color
          }
          dates.push hash
        end
      end
    end
    return dates
  end
end
