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
#  expense_one_img         :string(255)
#  expense_two_img         :string(255)
#  customer_comments       :text
#  ba_comments             :text
#  product_one_price       :decimal(8, 2)
#  product_two_price       :decimal(8, 2)
#  product_three_price     :decimal(8, 2)
#  product_four_price      :decimal(8, 2)
#  product_one_sample      :integer
#  product_two_sample      :integer
#  product_three_sample    :integer
#  product_four_sample     :integer
#  expense_one             :decimal(8, 2)    default(0.0)
#  expense_two             :decimal(8, 2)    default(0.0)
#

require 'carrierwave/orm/activerecord'
class Report < ActiveRecord::Base
  belongs_to :service
  
  mount_uploader :expense_one_img, ImageUploader
  mount_uploader :expense_two_img, ImageUploader

  def sum_expense
    expense_one.to_f + expense_two.to_f
  end
end
