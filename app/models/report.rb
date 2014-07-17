# == Schema Information
#
# Table name: reports
#
#  id               :integer          not null, primary key
#  service_id       :integer
#  demo_in_store    :string(255)
#  weather          :string(255)
#  traffic          :string(255)
#  busiest_hours    :string(255)
#  price_comment    :string(255)
#  sample_units_use :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#

class Report < ActiveRecord::Base
end
