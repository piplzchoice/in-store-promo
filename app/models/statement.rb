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
#  data                :text
#

class Statement < ActiveRecord::Base
  serialize :services_ids
  serialize :line_items, JSON
  serialize :data, JSON
  belongs_to :brand_ambassador
  mount_uploader :file, ImageUploader

  def self.generate_data(service_ids)
    data = []

    service_ids.each_with_index do |service_id, i|
      service = Service.find(service_id)
      expenses = service.report_service.nil? ? "" : (service.report_service.expense_one.nil? ? "-" : ActionController::Base.helpers.number_to_currency(service.report_service.expense_one))
      travel_expense = service.report_service.nil? ? "" : (service.brand_ambassador.mileage ? (service.report_service.travel_expense.nil? ? "-" : ActionController::Base.helpers.number_to_currency(service.report_service.travel_expense)) : "-")
      item = {
        date: service.start_at.strftime('%m/%d/%Y'),
        client_name: service.company_name,
        location: service.location.name,
        rate: ActionController::Base.helpers.number_to_currency(service.ba_rate),
        expenses: expenses,
        travel_expense: travel_expense,
        total: ActionController::Base.helpers.number_to_currency(service.total_ba_paid)
      }
      data.push(item)
    end

    return data
  end

  def totals_ba_paid
    brand_ambassador.services.calculate_total_ba_paid(services_ids)
  end

  def totals_expenses
    data.collect{|x| x["expenses"].split("$").last.to_f}.sum
  end
end
