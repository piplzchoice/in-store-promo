if User.find_by_email('admin@ism.com').blank?
  user = User.create(email: 'admin@ism.com',
    password: '1q2w3e4r5t', password_confirmation: '1q2w3e4r5t')
  user.add_role :admin
  puts "user admin created"
end

if DefaultValue.all.size == 0
  DefaultValue.create(rate_project: 150)
  puts "default value created"
end

if DefaultValue.all.size == 1
  df = DefaultValue.first
  if df.sample_product.nil? && df.traffic.nil?
    df.sample_product = "Provided by Client;Store Inventory;Purchased"
    df.traffic = "Busy;Moderate;Slow"
    df.save
    puts "default value updated"
  end
end

if EmailTemplate.all.size == 0
  ba_assignment_notification = {
    name: "ba_assignment_notification", 
    subject: "You have been offered the following assignment",
    content: "
      <p>Dear .ba_name,
      <br />
      <p>You have been offered the following assignment, please accept or decline within 12 hours.</p>
      <br />
      <p>.service_company_name</p>
      <p>.service_location</p>
      <p>.service_complete_date</p>
      <p>.service_details</p>
      <br />
      <p>Please click on a link below to respond</p>
      <p><a href=\".link_confirm_respond\">Yes</a> or <a href=\".link_rejected_respond\">No</a><p>
      <br />
      <p>Thanks</p>"
  }

  cancel_assignment_notification = {
    name: "cancel_assignment_notification", 
    subject: "Demo was canceled",
    content: "
      <p>Hello, .ba_name</p>
      <br />
      <p>This demo .service_company_name, .service_date, .service_location was canceled. </p>
      <p>Sorry about inconvenience</p>    
      <br />
      <p>Thanks</p>
    "
  }

  ba_unrespond_assignment = {
    name: "ba_unrespond_assignment", 
    subject: "Unrespond Assignment",
    content: "
      <p>BA .ba_name has unrespond his assignment, here is the assigment :</p>
      <br />
      <p>.service_company_name</p>
      <p>.service_location</p>
      <p>.service_complete_date</p>
      <p>.service_details</p>
      <br />
      <p>Click <a href=\".project_link\">here</a> to edit service</p>
      <br />
      <p>Thanks</p>
    "
  }

  welcome_email = {
    name: "welcome_email", 
    subject: "Welcome to In Store Marketing",
    content: "
      <p>Dear .fullname</p>
      <br />
      <p>Please follow this <a href=\".root_link\">link</a> to access our online system. The system helps to streamline scheduling, reporting and payment processes.</p>
      <br />
      <p>You will need your username <strong>.email</strong> and password <strong>.password</strong> to login going forward, so please keep the information where it is readily accessible.</p>
      <br />
      <p>Thanks</p>
    "
  }

  reset_password = {
    name: "reset_password", 
    subject: "Your new password",
    content: "
      <h1>Your new password</h1>
      <p>
        your email is: .email<br>
        your new password is: <strong>.password</strong><br>
      </p>
      <p>Thanks</p>
    "
  }

  EmailTemplate.create(ba_assignment_notification)
  EmailTemplate.create(cancel_assignment_notification)
  EmailTemplate.create(ba_unrespond_assignment)
  EmailTemplate.create(welcome_email)
  EmailTemplate.create(reset_password)

  puts "email template created"
end

if EmailTemplate.find_by_name("send_reminder_to_add_availablty_date").nil?
  send_reminder_to_add_availablty_date = {
    name: "send_reminder_to_add_availablty_date", 
    subject: "Add Availablty Date",
    content: "
      <p>Dear .ba_name</p>
      <p>Please don't forget to add your availablty date</p>
      <p>Thanks</p>
    "  
  }  
  EmailTemplate.create(send_reminder_to_add_availablty_date)

  puts "created email template for send_reminder_to_add_availablty_date"
end

# if DefaultValue.first.service_hours_est.nil?
#   dv = DefaultValue.first
#   dv.service_hours_est = 4
#   dv.save
#   puts "service_hours_est added"
# end

if DefaultValue.first.send_unrespond.nil?
  dv = DefaultValue.first
  dv.send_unrespond = 12
  dv.save
  puts "send_unrespond added"
end

if DefaultValue.first.co_op_price.nil?
  dv = DefaultValue.first
  dv.co_op_price = 100
  dv.save
  puts "co_op_price added"  
end

if EmailTemplate.find_by_name("ba_is_paid").nil?
  ba_is_paid = {
    name: "ba_is_paid", 
    subject: "You have been paided",
    content: "
      <p>Hello .ba_name,</p>
      <p>Payment was processed today to pay you for the following services (see attached).</p>
      <p>You should expect the check from our bank within 5-6 days.</p>
    "  
  }  
  EmailTemplate.create(ba_is_paid)

  puts "created email template for ba_is_paid"
end

if EmailTemplate.find_by_name("send_invoice").nil?
  send_invoice = {
    name: "send_invoice", 
    subject: "You have been paided",
    content: "
      <p>Hello</p>
      <p>Here is the invoice</p>
    "  
  }  
  EmailTemplate.create(send_invoice)

  puts "created email template for send_invoice"  
end

if EmailTemplate.find_by_name("report_over_due_alert").nil?
  report_over_due_alert = {
    name: "report_over_due_alert", 
    subject: "Alert, Report Over Due",
    content: "
      <p>The report for the demo conducted on <strong>.demo_date</strong> for <strong>.service_company_name</strong> at <strong>.service_location</strong> is over due.</p>
      <p>Please complete the report ASAP as it cannot be invoiced for without you doing it.</p>
    "  
  }  
  EmailTemplate.create(report_over_due_alert)

  puts "created email template for report_over_due_alert"  
end

if EmailTemplate.find_by_name("thank_you_for_payment").nil?
  thank_you_for_payment = {
    name: "thank_you_for_payment", 
    subject: "Thank you for payment",
    content: "
      <p>Dear .client_first_name ,</p>
      <p>We have received your payment of .amount_received .</p>

      <p>Thanks for the payment and your business.</p>
      <p>We look forward to working with you again.</p>
    "  
  }  
  EmailTemplate.create(thank_you_for_payment)

  puts "created email template for thank_you_for_payment"  
end


if EmailTemplate.find_by_name("service_has_been_modified").nil?
  service_has_been_modified = {
    name: "service_has_been_modified", 
    subject: "Service details has been modified",
    content: "
      <p>Hello, .ba_name</p>
      <br />    
      <p>Details of Demo .service_company_name, .service_date, .service_location was changed. </p>
      <p><a href=\".link_show_page\">Click here to see changes</a><p>
      <p>Thanks</p>
    "  
  }  
  EmailTemplate.create(service_has_been_modified)

  puts "created email template for service_has_been_modified"  
end

if EmailTemplate.find_by_name("inventory_confirmed_no").nil?
  inventory_confirmed_no = {
    name: "inventory_confirmed_no", 
    subject: "Service inventory is not confirmed yet",
    content: "
      <p>This service inventory is not confirmed yet</p>
      <br />
      <p>.service_company_name</p>
      <p>.service_location</p>
      <p>.service_complete_date</p>
      <p>.service_details</p>
      <br />
      <p>Click <a href=\".project_link\">here</a> to view service</p>
      <br />
      <p>Thanks</p>
    "
  }  
  EmailTemplate.create(inventory_confirmed_no)

  puts "created email template for inventory_confirmed_no"  
end