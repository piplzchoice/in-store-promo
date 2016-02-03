# == Schema Information
#
# Table name: logs
#
#  id         :integer          not null, primary key
#  service_id :integer
#  origin     :integer
#  latest     :integer
#  created_at :datetime
#  updated_at :datetime
#

class Log < ActiveRecord::Base
  belongs_to :service
  validates :origin, :latest, presence: true

  def self.create_data(service_id, origin, latest)
    log = self.new
    log.service_id = service_id
    log.origin = origin
    log.latest = latest
    log.save
  end
end
