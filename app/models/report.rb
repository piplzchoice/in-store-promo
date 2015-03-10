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
#  product_five_sample     :integer
#  product_five_price      :decimal(8, 2)
#  product_five            :string(255)
#  product_five_beginning  :integer
#  product_five_end        :integer
#  product_five_sold       :integer
#  product_six_sample      :integer
#  product_six_price       :decimal(8, 2)
#  product_six             :string(255)
#  product_six_beginning   :integer
#  product_six_end         :integer
#  product_six_sold        :integer
#  table_image_one_img     :string(255)
#  table_image_two_img     :string(255)
#  is_active               :boolean          default(TRUE)
#  travel_expense          :decimal(8, 2)
#  client_products         :text
#

require 'carrierwave/orm/activerecord'
class Report < ActiveRecord::Base
  
  belongs_to :service
  
  mount_uploader :expense_one_img, ImageUploader
  mount_uploader :expense_two_img, ImageUploader
  mount_uploader :table_image_one_img, ImageUploader
  mount_uploader :table_image_two_img, ImageUploader

  
  # validates :est_customer_touched, presence: true

  serialize :client_products, JSON

  def self.new_data(report_params)
    report = self.new(report_params)
    report.client_products = report.client_products.collect do |product|
      arr_val = [product[:price], product[:sample], product[:beginning], product[:end], product[:sold]].uniq
      product unless arr_val.size == 1 || (arr_val.size == 1 && arr_val.size  != "")
    end

    report.client_products = report.client_products.compact
    return report
  end

  def sum_expense
    expense_one.to_f + expense_two.to_f
  end

  def set_data_true
    self.update_attribute(:is_active, true)
  end

  def set_data_false
    self.update_attribute(:is_active, false)
  end         

  def total_units_sold
    total = 0
    total += (product_one_sold.nil? ? 0 : product_one_sold)
    total += (product_two_sold.nil? ? 0 : product_two_sold)
    total += (product_three_sold.nil? ? 0 : product_three_sold)
    total += (product_four_sold.nil? ? 0 : product_four_sold)
    total += (product_five_sold.nil? ? 0 : product_five_sold)
    total += (product_six_sold.nil? ? 0 : product_six_sold)
  end

  def ave_product_price
    total_price, available_product = 0, 0
    total_price, available_product = (total_price + product_one_price), (available_product + 1) unless product_one_price.nil?
    total_price, available_product = (total_price + product_two_price), (available_product + 1) unless product_two_price.nil?
    total_price, available_product = (total_price + product_three_price), (available_product + 1) unless product_three_price.nil?
    total_price, available_product = (total_price + product_four_price), (available_product + 1) unless product_four_price.nil?
    total_price, available_product = (total_price + product_five_price), (available_product + 1) unless product_five_price.nil?
    total_price, available_product = (total_price + product_six_price), (available_product + 1) unless product_six_price.nil?
    return (total_price / available_product).round(2) rescue "-"
  end
end
