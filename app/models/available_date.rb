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
          available_date.save           
        end      
      end          
    end
  end

end
