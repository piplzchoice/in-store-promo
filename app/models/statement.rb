# == Schema Information
#
# Table name: statements
#
#  id                  :integer          not null, primary key
#  brand_ambassador_id :integer
#  file                :string(255)
#  state_no            :string(255)
#  created_at          :datetime
#  updated_at          :datetime
#  services_ids        :text
#

class Statement < ActiveRecord::Base
  serialize :services_ids  
  belongs_to :brand_ambassador
  mount_uploader :file, ImageUploader
end
