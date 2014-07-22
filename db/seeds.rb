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