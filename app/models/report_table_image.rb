# == Schema Information
#
# Table name: report_table_images
#
#  id         :integer          not null, primary key
#  report_id  :integer
#  file       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class ReportTableImage < ActiveRecord::Base
  belongs_to :report

  mount_uploader :file, ImageUploader
end
