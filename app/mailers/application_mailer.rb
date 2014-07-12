class ApplicationMailer < ActionMailer::Base
  default from: "from@example.com"

  def welcome_email(email, fullname, password)
    @email = email
    @password = password
    @fullname = fullname
    mail(to: email, subject: 'Welcome to In Store Marketing')
  end

  def reset_password(email, fullname, password)
    @email = email
    @password = password
    mail(to: email, subject: 'Your new password')
  end  

  def ba_assignment_notification(ba, service)
    @ba = ba
    @service = service
    mail(to: @ba.account.email, subject: 'You have been offered the following assignment')
  end

  def reminder_to_ba(ba_email, ba_name, date)
  end

  def cancel_assignment_notification(ba, service)
    @ba = ba
    @service = service
    mail(to: @ba.account.email, subject: "Demo was canceled")
  end

  def ba_unrespond_assignment
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