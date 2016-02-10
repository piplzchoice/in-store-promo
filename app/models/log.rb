# == Schema Information
#
# Table name: logs
#
#  id         :integer          not null, primary key
#  service_id :integer
#  created_at :datetime
#  updated_at :datetime
#  user_id    :integer
#  category   :integer
#  data       :text
#

class Log < ActiveRecord::Base
  belongs_to :service
  belongs_to :user
  # validates :origin, :latest, presence: true
  serialize :data, JSON
  enum category: [ :status_changed, :modified_details, :modified_main ]

  def self.create_data(service_id, origin, latest)
    log = self.new
    log.service_id = service_id
    log.origin = origin
    log.latest = latest
    log.save
  end

  def self.record_status_changed(service_id, origin, latest, current_user_id)
    log = self.new
    log.category = :status_changed
    log.service_id = service_id
    log.user_id = current_user_id
    log.data = {origin: origin, latest: latest}
    log.save    
  end

  def self.record_modified_details(service_id, old_data, new_data, current_user_id)
    log = self.new
    log.category = :modified_details
    log.service_id = service_id
    log.user_id = current_user_id
    log.data = {old: old_data, new: new_data}
    log.save    
  end

  def self.record_modified_main(service_id, old_data, new_data, latest, current_user_id)
    log = self.new
    log.category = :modified_main
    log.service_id = service_id
    log.user_id = current_user_id
    log.data = {old: old_data, new: new_data, origin: old_data["status"], latest: latest}
    log.save    
  end  

end
