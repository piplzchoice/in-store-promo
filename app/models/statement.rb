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
#

class Statement < ActiveRecord::Base
  belongs_to :brand_ambassador
  mount_uploader :file, ImageUploader
end
