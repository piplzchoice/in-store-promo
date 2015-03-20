# == Schema Information
#
# Table name: report_expense_images
#
#  id         :integer          not null, primary key
#  report_id  :integer
#  file       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class ReportExpenseImage < ActiveRecord::Base
  belongs_to :report

  mount_uploader :file, ImageUploader
end
