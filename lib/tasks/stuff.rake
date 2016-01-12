namespace :stuff do
  desc "Modified value of report"
  task :formula_report_change => :environment do
    Report.all.each do |report|

      unless report.product_one.nil?
        unless report.product_one_beginning.nil? && report.product_one_end.nil? && report.product_one_sample.nil?
          report.product_one_beginning = report.product_one_beginning.nil? ? 0 : report.product_one_beginning
          report.product_one_end = report.product_one_end.nil? ? 0 : report.product_one_end
          report.product_one_sample = report.product_one_sample.nil? ? 0 : report.product_one_sample
          report.product_one_sold = report.product_one_beginning - report.product_one_end - report.product_one_sample
        end
      end

      unless report.product_two.nil?
        unless report.product_two_beginning.nil? && report.product_two_end.nil? && report.product_two_sample.nil?
          report.product_two_beginning = report.product_two_beginning.nil? ? 0 : report.product_two_beginning
          report.product_two_end = report.product_two_end.nil? ? 0 : report.product_two_end
          report.product_two_sample = report.product_two_sample.nil? ? 0 : report.product_two_sample
          report.product_two_sold = report.product_two_beginning - report.product_two_end - report.product_two_sample
        end
      end

      unless report.product_three.nil?
        unless report.product_three_beginning.nil? && report.product_three_end.nil? && report.product_three_sample.nil?
          report.product_three_beginning = report.product_three_beginning.nil? ? 0 : report.product_three_beginning
          report.product_three_end = report.product_three_end.nil? ? 0 : report.product_three_end
          report.product_three_sample = report.product_three_sample.nil? ? 0 : report.product_three_sample
          report.product_three_sold = report.product_three_beginning - report.product_three_end - report.product_three_sample
        end
      end

      unless report.product_four.nil?
        unless report.product_four_beginning.nil? && report.product_four_end.nil? && report.product_four_sample.nil?
          report.product_four_beginning = report.product_four_beginning.nil? ? 0 : report.product_four_beginning
          report.product_four_end = report.product_four_end.nil? ? 0 : report.product_four_end
          report.product_four_sample = report.product_four_sample.nil? ? 0 : report.product_four_sample
          report.product_four_sold = report.product_four_beginning - report.product_four_end - report.product_four_sample
        end
      end

      unless report.product_five.nil?
        unless report.product_five_beginning.nil? && report.product_five_end.nil? && report.product_five_sample.nil?
          report.product_five_beginning = report.product_five_beginning.nil? ? 0 : report.product_five_beginning
          report.product_five_end = report.product_five_end.nil? ? 0 : report.product_five_end
          report.product_five_sample = report.product_five_sample.nil? ? 0 : report.product_five_sample
          report.product_five_sold = report.product_five_beginning - report.product_five_end - report.product_five_sample
        end
      end

      unless report.product_six.nil?
        unless report.product_six_beginning.nil? && report.product_six_end.nil? && report.product_six_sample.nil?
          report.product_six_beginning = report.product_six_beginning.nil? ? 0 : report.product_six_beginning
          report.product_six_end = report.product_six_end.nil? ? 0 : report.product_six_end
          report.product_six_sample = report.product_six_sample.nil? ? 0 : report.product_six_sample
          report.product_six_sold = report.product_six_beginning - report.product_six_end - report.product_six_sample
        end
      end

      report.save

    end
  end

  desc "Update all user password to default"
  task :update_users_password => :environment do
    User.all.each do |user|
      user.update_attributes({password: "1q2w3e4r5t", password_confirmation: "1q2w3e4r5t"})
    end
  end

  desc "Update projects status"
  task :update_projects_status => :environment do
    Project.all.each do |project|
      if project.services.size != 0
        project.update_attribute(:status, Project.status_active)
      end
    end
  end

  desc "Update projects deactivated status"
  task :update_projects_deactivated_status => :environment do
    Project.all.each do |project|
      if project.status == Project.status_completed
        project.set_data_false
      elsif !project.is_active
        project.set_as_complete
      end
    end
  end

  desc "merge service to client"
  task :merge_service_to_client => :environment do
    Service.all.each do |service|
      unless service.project.nil?
        client = service.project.client
        service.update_attribute(:client_id, client.id)
        client.update_attribute(:rate, 150)
      end
    end
  end

  desc "get id data of report"
  task :id_reports => :environment do
    Report.where.not(client_products: nil).each do |report|
      unless report.client_products.nil?
        report.client_products.each do |client_product|
          product = Product.find_by_name(client_product["name"])
          unless product.nil?
            client_product["id"] = product.id
          end
        end
        report.save!
      end
    end
  end

  desc "import image to new data image report"
  task :import_image_report => :environment do
    Report.all.each do |report|
      puts "importing image for report id: #{report.id}"

      unless report.expense_one_img.nil?
        expense_image = report.report_expense_images.build
        expense_image.remote_file_url = report.expense_one_img.url
        expense_image.save
      end

      unless report.expense_two_img.nil?
        expense_image = report.report_expense_images.build
        expense_image.remote_file_url = report.expense_two_img.url
        expense_image.save
      end

      unless report.table_image_one_img.nil?
        table_image = report.report_table_images.build
        table_image.remote_file_url = report.table_image_one_img.url
        table_image.save
      end

      unless report.table_image_two_img.nil?
        table_image = report.report_table_images.build
        table_image.remote_file_url = report.table_image_two_img.url
        table_image.save
      end
    end
  end

  desc "import data to new data"
  task :import_data_invoice => :environment do
    Invoice.where(data: nil).each do |invoice|
      data = []
      invoice.service_ids.split(",").each do |service_id|
        service = Service.find(service_id)
        product_expenses = service.report_service.nil? ? "" : ActionController::Base.helpers.number_to_currency(service.report_service.expense_one)
        travel_expense = service.report_service.nil? ? "" : (service.brand_ambassador.mileage ? (service.report_service.travel_expense.nil? ? "-" : ActionController::Base.helpers.number_to_currency(service.report_service.travel_expense)) : "-")
        item = {
          service_id: service_id,
          demo_date: service.start_at.strftime('%m/%d/%Y'),
          start_time: service.start_at.strftime("%I:%M %p"),
          rate: ActionController::Base.helpers.number_to_currency((service.client.nil? ? "" : service.client.rate)),
          product_expenses: product_expenses,
          travel_expense: travel_expense,
          amount: ActionController::Base.helpers.number_to_currency(service.grand_total)
        }

        data.push(item)
      end          
      
      invoice.data = data     
      invoice.save 
      puts "save invoice id: #{invoice.id}"
    end
  end

  desc "import data to new data statement"
  task :import_data_statement => :environment do
    Statement.where(data: nil).each do |statement|
      data = []
      statement.services_ids.each do |service_id|
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
          total: service.report_service.nil? ? 0 : ActionController::Base.helpers.number_to_currency(service.total_ba_paid)
        }

        data.push(item)
      end          
      
      statement.data = data     
      statement.save 
      puts "save statement id: #{statement.id}"
    end
  end

  desc "update email content assignment"
  task :update_email_assignment_content => :environment do
    et = EmailTemplate.find_by_name("ba_assignment_notification")
    ba_assignment_notification = {
      content: "
        <p>Dear .ba_name,
        <br />
        <p>You have been offered the following assignment, please accept or decline as soon as you can. If you do not respond within 12 hours, this assignment will be offered to another Brand Ambassador.</p>
        <br />
        <p>Please click on a link below to respond</p>
        <p><a href=\".link_confirm_respond\">Yes</a> or <a href=\".link_rejected_respond\">No</a><p>
        <br />
        <p>.service_company_name</p>
        <p>.service_location</p>
        <p>.service_complete_date</p>
        <p>.service_details</p>
        <p>.service_products</p>
        <br />        
        <p>Thanks</p>"
    }    
    puts "update email content" if et.update_attributes(ba_assignment_notification)    
  end

end
