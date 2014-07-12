# == Schema Information
#
# Table name: available_dates
#
#  id                  :integer          not null, primary key
#  brand_ambassador_id :integer
#  availablty          :date
#  created_at          :datetime
#  updated_at          :datetime
#

class AvailableDate < ActiveRecord::Base
  belongs_to :brand_ambassador

  validates :availablty, presence: true

  def self.new_data(params)
    params[:availablty] = Date.strptime(params[:availablty], '%m/%d/%Y') unless params[:availablty].blank?
    self.new(params)
  end

end
