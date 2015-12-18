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
  has_many :statements
  has_and_belongs_to_many :territories
  has_and_belongs_to_many :locations

  default_scope { order("created_at ASC") }
  scope :with_status_active, -> { where(is_active: true) }

  def self.filter_and_order(filter_options)
    data = []
    if filter_options["location_name"] == ""
      data = BrandAmbassador.where(is_active: filter_options["is_active"])
    else
      data = Location.find(filter_options["location_name"]).brand_ambassadors.where(is_active: filter_options["is_active"])
    end    
    return data    
  end    

  def self.new_with_account(brand_ambassador_params, user_id)
    brand_ambassador = self.new(brand_ambassador_params)
    brand_ambassador.user_id = user_id
    brand_ambassador.build_account(brand_ambassador_params["account_attributes"])
    password = Devise.friendly_token.first(8)
    brand_ambassador.account.password = password
    brand_ambassador.account.password_confirmation = password
    brand_ambassador.account.add_role :ba   
    return brand_ambassador, password
  end

  def self.get_available_people(start_at, end_at, service_id, location_id)

    start_time = DateTime.strptime(start_at, '%m/%d/%Y %I:%M %p')
    end_time = DateTime.strptime(end_at, '%m/%d/%Y %I:%M %p')    
    time_range = start_time.midnight..(start_time.midnight + 1.day - 1.minutes)

    ba_data = nil
    location = Location.find(location_id)

    if location.brand_ambassadors.empty?
      ba_data = BrandAmbassador.joins(:available_dates).where(is_active: true, available_dates: {availablty: time_range})
    else
      ba_data = BrandAmbassador.joins(:available_dates).where(
        is_active: true, 
        id: location.brand_ambassadors.collect(&:id), 
        available_dates: {availablty: time_range}
      )
    end
    
    
    
    filtered_ba_data = ba_data.collect do |ba|
      services = ba.services.where({start_at: time_range}).where.not({status: [Service.status_cancelled, Service.status_rejected]})
      available_date = ba.available_dates.where({availablty: time_range}).first

      if services.blank?
        if start_time.strftime("%p") == "AM" && available_date.am
          ba
        elsif start_time.strftime("%p") == "PM" && available_date.pm
          ba
        end
      else
        statement = services.collect do |service|
          service.is_overlap?(start_time, end_time)
        end

        if !statement.include?(true)
          if start_time.strftime("%p") == "AM" && available_date.am
            ba
          elsif start_time.strftime("%p") == "PM" && available_date.pm
            ba
          end          
        end
      end
    end

    unless service_id == ""
      service = Service.find service_id
      if service.start_at.strftime("%m/%d/%Y") == start_time.strftime("%m/%d/%Y")
        filtered_ba_data.push service.brand_ambassador
      end
    end

    filtered_ba_data.uniq.compact.flatten
  end

  def self.process_payments(service_ids)
    data = service_ids.collect{|x| x.split("-")}
    hash_data = {}
    data.each do |x|
      if hash_data.has_key?(x.first)
        hash_data[x.first].push x.last
      else
        hash_data[x.first] = [x.last]
      end
    end    

    return hash_data
  end

  def name_split
    new_name = name.strip.split(" ")
    "#{new_name.first} #{new_name.last.first}"
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
    # available_dates.collect{|x| {title: "", 
    #   start: x.availablty.strftime("%Y-%m-%d") } }

    dates = []
    data = nil
    ba = self

    ba.available_dates.each do |available_date| 
      time_range = available_date.availablty.midnight..(available_date.availablty.midnight + 1.day - 1.minutes)
      hash_data = {start_at: time_range}
      
      # unless location_name == "0"
      #   hash_data = hash_data.merge({location_id: location_name})
      # end        

      services = ba.services.select(:id, :start_at, :status, :client_id, :location_id).where(hash_data).where.not({status: 9})

      show = true
      show_service = false

      if services.blank?
        if available_date.am && available_date.pm
          color = "#3c763d" #green
        elsif available_date.am && !available_date.pm
          color = "#f0ad4e" #orange
        elsif !available_date.am && available_date.pm
          color = "#428bca" #blue
        end                  
      else
        periods = services.collect{|x| x.start_at.strftime("%p") }
        if periods.size == 2
          show = false
        else
          if services.first.status != Service.status_rejected
            if periods.include?("AM")
              if available_date.am && available_date.pm
                color = "#428bca"
                show_service = true
              else
                show = false
              end                     
            elsif periods.include?("PM")
              if available_date.am && available_date.pm
                # color = "#f0ad4e"
                service = services.first
                if [12, 1].include?(service.start_at.strftime("%I").to_i)
                  show = false
                else
                  color = "#f0ad4e" #orange
                  show_service = true
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

      # if show_service
      #   services.each do |service|
      #     hash = {
      #       title: "#{ba.name} - #{service.client.company_name} (#{service.location.name}) : #{service.start_at.strftime("%m/%d/%Y %I:%M %p")}",
      #       start: service.start_at.strftime("%Y-%m-%d"),
      #       url: Rails.application.routes.url_helpers.client_service_path({client_id: service.client_id, id: service.id}),
      #       color: "#92D050"
      #     }   
      #     dates.push hash
      #   end          
      # end      
    end

    services.collect{|x|
      if x.status == 2 || x.status == 4 || x.status == 11
        hash = {
          title: x.title_calendar, 
          start: x.start_at.iso8601, 
          end: x.end_at.iso8601,
          color: x.get_color,
          url: Rails.application.routes.url_helpers.assignment_path({id: x.id})
        }
        dates.push hash
      end
    }      
    
    return dates.compact.uniq    
  end

  def disable_dates
    available_dates.all.collect{|x| x.availablty.strftime("%m/%d/%Y")}.to_json
  end

  def get_monthly_date(date)
    available_dates.where(availablty: Date.new(date[:year].to_i, date[:month].to_i).beginning_of_month..Date.new(date[:year].to_i, date[:month].to_i).end_of_month)
  end

  def get_assignments
    services.collect{|x|
      if x.status == 2 || x.status == 4 || x.status == 11
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

  def self.get_all_available_dates(location_name)
    # "#3c763d" green
    # "#f0ad4e" orange
    # "#428bca" blue
    # "#92D050" confirmed
    #
    # new process
    #
    # 1. Show BA availability for am and pm (done)

    # 2. Show BA booking day (done)

    # 3. When BA have availability for am and pm, and  BA have booking at the pm time, availability data on am and booking data is shown

    # 4. When BA have availability for am and pm, and  BA have booking at the am time, availability data on pm and booking data is shown

    # 5. When ba have availability for am and pm and both of time is booked, then data service should not shown.

    # 6. When ba only have availability time on pm and is booked, booking will not shown    

    dates = []
    data = nil
    
    if location_name == "0"
      data = self.with_status_active
    else
      data = Location.find(location_name).brand_ambassadors.with_status_active
    end

    data.all.each do |ba|
      ba.available_dates.each do |available_date| 
        time_range = available_date.availablty.midnight..(available_date.availablty.midnight + 1.day - 1.minutes)
        hash_data = {start_at: time_range}
        
        # unless location_name == "0"
        #   hash_data = hash_data.merge({location_id: location_name})
        # end        

        services = ba.services.select(:id, :start_at, :status, :client_id, :location_id).where(hash_data).where.not({status: 9})

        show = true
        show_service = false

        if services.blank?
          if available_date.am && available_date.pm
            color = "#3c763d" #green
          elsif available_date.am && !available_date.pm
            color = "#f0ad4e" #orange
          elsif !available_date.am && available_date.pm
            color = "#428bca" #blue
          end                  
        else
          periods = services.collect{|x| x.start_at.strftime("%p") }
          if periods.size == 2
            show = false
          else
            if services.first.status != Service.status_rejected
              if periods.include?("AM")
                if available_date.am && available_date.pm
                  color = "#428bca"
                  show_service = true
                else
                  show = false
                end                     
              elsif periods.include?("PM")
                if available_date.am && available_date.pm
                  # color = "#f0ad4e"
                  service = services.first
                  if [12, 1].include?(service.start_at.strftime("%I").to_i)
                    show = false
                  else
                    color = "#f0ad4e" #orange
                    show_service = true
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

        # show = true
        # color = "#3c763d"

        if show
          hash = {
            title: ba.name,
            start: available_date.availablty.strftime("%Y-%m-%d"),
            url: Rails.application.routes.url_helpers.brand_ambassador_path(ba),
            color: color
          }
          dates.push hash
        end

        if show_service
          services.each do |service|
            hash = {
              title: "#{ba.name} - #{service.client.company_name} (#{service.location.name}) : #{service.start_at.strftime("%m/%d/%Y %I:%M %p")}",
              start: service.start_at.strftime("%Y-%m-%d"),
              url: Rails.application.routes.url_helpers.client_service_path({client_id: service.client_id, id: service.id}),
              color: "#92D050"
            }   
            dates.push hash     
          end          
        end
      end
      
      # data_criteria = {:status => 2}
      # unless location_name == "0"
      #   data_criteria = data_criteria.merge({location_id: location_name})
      # end            

      # ba.services.where(data_criteria).each do |service|
      #   hash = {
      #     title: "#{ba.name} - #{service.client.company_name} (#{service.location.name}) : #{service.start_at.strftime("%m/%d/%Y %I:%M %p")}",
      #     start: service.start_at.strftime("%Y-%m-%d"),
      #     url: Rails.application.routes.url_helpers.client_service_path({client_id: service.client_id, id: service.id}),
      #     color: "#92D050"
      #   }   
      #   dates.push hash     
      # end


    end
    return dates.uniq
  end
end
