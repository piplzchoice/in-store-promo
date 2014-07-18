# == Schema Information
#
# Table name: reports
#
#  id                      :integer          not null, primary key
#  service_id              :integer
#  demo_in_store           :string(255)
#  weather                 :string(255)
#  traffic                 :string(255)
#  busiest_hours           :string(255)
#  price_comment           :string(255)
#  sample_units_use        :string(255)
#  created_at              :datetime
#  updated_at              :datetime
#  products                :string(255)
#  product_one             :string(255)
#  product_one_beginning   :integer
#  product_one_end         :integer
#  product_one_sold        :integer
#  product_two             :string(255)
#  product_two_beginning   :integer
#  product_two_end         :integer
#  product_two_sold        :integer
#  product_three           :string(255)
#  product_three_beginning :integer
#  product_three_end       :integer
#  product_three_sold      :integer
#  product_four            :string(255)
#  product_four_beginning  :integer
#  product_four_end        :integer
#  product_four_sold       :integer
#  sample_product          :string(255)
#  est_customer_touched    :string(255)
#  est_sample_given        :string(255)
#  expense_one             :string(255)
#  expense_one_img         :string(255)
#  expense_two             :string(255)
#  expense_two_img         :string(255)
#  customer_comments       :text
#  price_value_comment     :decimal(8, 2)
#

class Report < ActiveRecord::Base
  belongs_to :service
end
