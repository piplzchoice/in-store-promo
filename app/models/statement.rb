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
#  line_items          :text
#  grand_total         :decimal(8, 2)
#

class Statement < ActiveRecord::Base
  serialize :services_ids  
  serialize :line_items, JSON
  belongs_to :brand_ambassador  
  mount_uploader :file, ImageUploader
end
