# == Schema Information
#
# Table name: reports
#
#  id                       :integer          not null, primary key
#  service_id               :integer
#  demo_in_store            :string(255)
#  weather                  :string(255)
#  traffic                  :string(255)
#  busiest_hours            :string(255)
#  created_at               :datetime
#  updated_at               :datetime
#  products                 :string(255)
#  product_one              :string(255)
#  product_one_beginning    :integer
#  product_one_end          :integer
#  product_one_sold         :integer
#  product_two              :string(255)
#  product_two_beginning    :integer
#  product_two_end          :integer
#  product_two_sold         :integer
#  product_three            :string(255)
#  product_three_beginning  :integer
#  product_three_end        :integer
#  product_three_sold       :integer
#  product_four             :string(255)
#  product_four_beginning   :integer
#  product_four_end         :integer
#  product_four_sold        :integer
#  sample_product           :string(255)
#  est_customer_touched     :string(255)
#  est_sample_given         :string(255)
#  expense_one_img          :string(255)
#  expense_two_img          :string(255)
#  customer_comments        :text
#  ba_comments              :text
#  product_one_price        :decimal(8, 2)
#  product_two_price        :decimal(8, 2)
#  product_three_price      :decimal(8, 2)
#  product_four_price       :decimal(8, 2)
#  product_one_sample       :integer
#  product_two_sample       :integer
#  product_three_sample     :integer
#  product_four_sample      :integer
#  expense_one              :decimal(8, 2)    default(0.0)
#  expense_two              :decimal(8, 2)    default(0.0)
#  product_five_sample      :integer
#  product_five_price       :decimal(8, 2)
#  product_five             :string(255)
#  product_five_beginning   :integer
#  product_five_end         :integer
#  product_five_sold        :integer
#  product_six_sample       :integer
#  product_six_price        :decimal(8, 2)
#  product_six              :string(255)
#  product_six_beginning    :integer
#  product_six_end          :integer
#  product_six_sold         :integer
#  table_image_one_img      :string(255)
#  table_image_two_img      :string(255)
#  is_active                :boolean          default(TRUE)
#  travel_expense           :decimal(8, 2)
#  client_products          :text
#  file_pdf                 :string(255)
#  client_coop_products     :text
#  hide_client_name         :boolean          default(FALSE)
#  hide_client_product      :boolean          default(FALSE)
#  hide_client_coop_name    :boolean          default(FALSE)
#  hide_client_coop_product :boolean          default(FALSE)
#  is_old_report            :boolean          default(TRUE)
#

require 'carrierwave/orm/activerecord'
class Report < ActiveRecord::Base
  
  belongs_to :service
  has_many :report_expense_images
  has_many :report_table_images
  
  mount_uploader :expense_one_img, ImageUploader
  mount_uploader :expense_two_img, ImageUploader
  mount_uploader :table_image_one_img, ImageUploader
  mount_uploader :table_image_two_img, ImageUploader
  mount_uploader :file_pdf, ImageUploader
  
  # validates :est_customer_touched, presence: true

  serialize :client_products, JSON
  serialize :client_coop_products, JSON

  def self.new_data(report_params)
    report = self.new(report_params)
    
    report.client_products = report.client_products.collect do |product|
      arr_val = [product[:price], product[:sample], product[:beginning], product[:end], product[:sold]].uniq
      product unless arr_val.size == 1 || (arr_val.size == 1 && arr_val.size  != "")
    end

    report.client_products = report.client_products.compact

    unless report.client_coop_products.nil?
      report.client_coop_products = nil
    end

    report.is_old_report = false

    return report
  end

  def self.new_coop_data(report_params, coop_id)
    report = self.new(report_params)  

    report.client_products = report.client_coop_products.collect do |product|
      arr_val = [product[:price], product[:sample], product[:beginning], product[:end], product[:sold]].uniq
      product unless arr_val.size == 1 || (arr_val.size == 1 && arr_val.size  != "")
    end

    report.client_products = report.client_products.compact
    report.client_coop_products = nil

    report.is_old_report = false
    report.service_id = coop_id

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
    if client_products.nil?
      total += (product_one_sold.nil? ? 0 : product_one_sold)
      total += (product_two_sold.nil? ? 0 : product_two_sold)
      total += (product_three_sold.nil? ? 0 : product_three_sold)
      total += (product_four_sold.nil? ? 0 : product_four_sold)
      total += (product_five_sold.nil? ? 0 : product_five_sold)
      total += (product_six_sold.nil? ? 0 : product_six_sold)
    else
      client_products.each_with_index do |product, i|
        total += (product["sold"].nil? ? 0 : product["sold"].to_f)
      end      
    end
    return total
  end

  def ave_product_price
    total_price, available_product = 0, 0
    if client_products.nil?
      total_price, available_product = (total_price + product_one_price), (available_product + 1) unless product_one_price.nil?
      total_price, available_product = (total_price + product_two_price), (available_product + 1) unless product_two_price.nil?
      total_price, available_product = (total_price + product_three_price), (available_product + 1) unless product_three_price.nil?
      total_price, available_product = (total_price + product_four_price), (available_product + 1) unless product_four_price.nil?
      total_price, available_product = (total_price + product_five_price), (available_product + 1) unless product_five_price.nil?
      total_price, available_product = (total_price + product_six_price), (available_product + 1) unless product_six_price.nil?
    else
      client_products.each_with_index do |product, i|
        total_price, available_product = (total_price + product["price"].to_f), (available_product + 1) unless product["price"].nil?
      end         
    end
    return (total_price / available_product).round(2) rescue "-"
  end

  def self.generate_export_data
    services = Report.all.collect{|x| x.service}.compact.sort{|x, y| y.report.id <=> x.report.id}

    export_data_array = [
      "Location Name", "Client name", "BA name", "Date", "Total Units Sold", "Ave Price",
      "Traffic", "Day", "AM/PM", "Product 1", "Product 2", "Product 3", "Product 4",
      "Product 5", "Product 6", "Product 7", "Product 8", "Product 9", "Product 10",
      "Product 11", "Product 12", "Product 13", "Product 14", "Product 15", "Sold Product 1",
      "Sold Product 2", "Sold Product 3", "Sold Product 4", "Sold Product 5", "Sold Product 6",
      "Sold Product 7", "Sold Product 8", "Sold Product 9", "Sold Product 10", "Sold Product 11",
      "Sold Product 12", "Sold Product 13", "Sold Product 14", "Sold Product 15", "Estimated 3 of customers touched"
    ]

    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet :name => 'Data'
    sheet1.row(0).replace(export_data_array)

    services.each_with_index do |service, i|
      sheet1.row(i + 1).replace service.export_data
    end

    export_file_path = [Rails.root, "tmp", "export-data-#{Time.now.to_i}.xls"].join("/")
    book.write(export_file_path)

    return export_file_path

  end
end