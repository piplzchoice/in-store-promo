# == Schema Information
#
# Table name: services
#
#  id                  :integer          not null, primary key
#  project_id          :integer
#  location_id         :integer
#  brand_ambassador_id :integer
#  user_id             :integer
#  created_at          :datetime
#  updated_at          :datetime
#  start_at            :datetime
#  end_at              :datetime
#  details             :text
#

class Service < ActiveRecord::Base
  belongs_to :user
  belongs_to :brand_ambassador
  belongs_to :location
  belongs_to :project

  validates :location_id, :brand_ambassador_id, :start_at, :end_at, presence: true

  def self.build_data(service_params)
    service_params[:start_at] = DateTime.strptime(service_params[:start_at], '%m/%d/%Y %I:%M %p') unless service_params[:start_at].blank?
    service_params[:end_at] = DateTime.strptime(service_params[:end_at], '%m/%d/%Y %I:%M %p')  unless service_params[:end_at].blank?
    self.new(service_params)
  end

  def title_calendar
    return "#{self.location.name} - #{self.brand_ambassador.name}"
  end

  def update_data(service_params)
    service_params[:start_at] = DateTime.strptime(service_params[:start_at], '%m/%d/%Y %I:%M %p') unless service_params[:start_at].blank?
    service_params[:end_at] = DateTime.strptime(service_params[:end_at], '%m/%d/%Y %I:%M %p')  unless service_params[:end_at].blank?    
    self.update_attributes(service_params)
  end

  def old_id
    ret = nil
    unless self.id.nil?
      service = Service.find self.id
      ret = service.brand_ambassador_id
    else
      ret == nil
    end
    return ret
  end
end
