# == Schema Information
#
# Table name: available_dates
#
#  id                  :integer          not null, primary key
#  brand_ambassador_id :integer
#  availablty          :date
#  created_at          :datetime
#  updated_at          :datetime
#  am                  :boolean          default(FALSE)
#  pm                  :boolean          default(FALSE)
#

class AvailableDate < ActiveRecord::Base
  belongs_to :brand_ambassador

  # validates :availablty, presence: true

  def self.new_data(params, ba)
    unless params.nil?
      params.each do |param|
        available_date = nil

        if param["id"].nil?        
          available_date = ba.available_dates.build
        else        
          available_date = ba.available_dates.find(param["id"])
        end

        if param["availablty"].nil?
          available_date.destroy
        else
          available_date.availablty = Date.strptime(param[:availablty], '%m/%d/%Y')
          available_date.am = param[:am]
          available_date.pm = param[:pm]
          available_date.no_both = param[:no_both]
          available_date.save           
        end      
      end          
    end
  end

  def get_color(services)
    # "#3c763d" => green    
    # "#428bca" => blue
    # "#f0ad4e" => yellow
    color = nil

    if services.blank?
      if am
        color = "#3c763d"
      else
        color = "#428bca"
      end
      # if am && pm
      #   color = "#3c763d"
      # elsif am && !pm
      #   color = "#f0ad4e"
      # elsif !am && pm
      #   color = "#428bca"
      # end
    else
      service = services.first     
      period = service.start_at.strftime("%p")
      if period == "AM"
        # if pm
          color = "#428bca"
        # end
      elsif period == "PM"
        # if am
          color = "#f0ad4e"
        # end
      end
      color = "red"
    end

    return color
  end

end
