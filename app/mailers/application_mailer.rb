class ApplicationMailer < ActionMailer::Base
  default from: "from@example.com"

  def welcome_email(email, fullname, password)
    et = EmailTemplate.find_by_name("welcome_email")
    @content = et.content.gsub(".email", email).gsub(".password", password)
    @content = @content.gsub(".fullname", fullname).gsub(".root_link", root_url)
    mail(to: email, subject: et.subject)
  end

  def reset_password(email, fullname, password)
    et = EmailTemplate.find_by_name("reset_password")
    @content = et.content.gsub(".email", email).gsub(".password", password)
    mail(to: email, subject: et.subject)
  end  

  def ba_assignment_notification(ba, service)
    et = EmailTemplate.find_by_name("ba_assignment_notification")

    @content = et.content.gsub(".ba_name", ba.name).gsub(".service_company_name", service.client_and_companyname)
    @content = @content.gsub(".service_location", service.location.complete_location).gsub(".service_complete_date", service.complete_date_time)
    @content = @content.gsub(".link_confirm_respond", confirm_respond_project_service_url(project_id: service.project.id, id: service.id, token: service.token))
    @content = @content.gsub(".link_rejected_respond", rejected_respond_project_service_url(project_id: service.project.id, id: service.id, token: service.token))

    mail(to: ba.account.email, subject: et.subject)
  end

  # def reminder_to_ba(ba_email, ba_name, date)
  # end

  def cancel_assignment_notification(ba, service)
    et = EmailTemplate.find_by_name("cancel_assignment_notification")

    @content = et.content.gsub(".ba_name", ba.name).gsub(".service_company_name", service.client_and_companyname)
    @content = @content.gsub(".service_location", service.location.complete_location).gsub(".service_date", service.date)    

    mail(to: ba.account.email, subject: et.subject)
  end

  def ba_unrespond_assignment(service)
    et = EmailTemplate.find_by_name("ba_unrespond_assignment")

    @content = et.content.gsub(".ba_name", service.brand_ambassador.name).gsub(".service_company_name", service.client_and_companyname)
    @content = @content.gsub(".service_location", service.location.complete_location).gsub(".service_complete_date", service.complete_date_time)
    @content = @content.gsub(".service_details", service.details).gsub(".project_link", edit_project_service_url(project_id: service.project.id, id: service.id ))

    mail(to: "carol.wellins@gmail.com", subject: et.subject)    
  end

  def send_ics(ba, service)
    mail(to: ba.account.email, subject: "Demo at #{service.client_and_companyname}, #{service.location.complete_location}") do |format|
       format.ics {
         ical = Icalendar::Calendar.new
         e = Icalendar::Event.new
         e.dtstart = service.start_at.utc
         e.dtend = service.end_at.utc
         e.summary = "Demo at #{service.client_and_companyname}, #{service.location.complete_location}"
         e.description = <<-EOF
           Date: #{service.complete_date_time}
           Client: #{service.client_and_companyname}
           Location: #{service.location.complete_location}           
           Details : #{service.details}
         EOF
         ical.add_event(e)
         ical.publish         
        render :text => ical.to_ical, :layout => false
      }
    end    
  end

end