class ApplicationMailer < ActionMailer::Base
  include ActionView::Helpers::NumberHelper
  default :from => "info@flavorfanaticsism.com"

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

    @content = et.content.gsub(".ba_name", ba.name).gsub(".service_company_name", service.client.company_name)
    @content = @content.gsub(".service_location", service.location.complete_location).gsub(".service_complete_date", service.complete_date_time)
    @content = @content.gsub(".link_confirm_respond", confirm_respond_client_service_url(client_id: service.client.id, id: service.id, token: service.token))
    @content = @content.gsub(".link_rejected_respond", rejected_respond_client_service_url(client_id: service.client.id, id: service.id, token: service.token))
    @content = @content.gsub(".service_details", service.details)

    elm = "<strong>Products:</strong>"
    elm += "<ul>"
    service.products.each{|x| elm += "<li>#{x.name}</li>"}
    if service.is_co_op?
      service.co_op_services.each do |srv|
        srv.products.each{|x| elm += "<li>#{x.name}</li>"}
      end
    end
    elm += "</ul>"

    @content = @content.gsub(".service_products", elm)

    mail(to: ba.account.email, subject: et.subject)
  end

  def service_has_been_modified(ba, service)
    et = EmailTemplate.find_by_name("service_has_been_modified")

    @content = et.content.gsub(".ba_name", ba.name).gsub(".service_company_name", service.client.company_name)
    @content = @content.gsub(".service_location", service.location.complete_location).gsub(".service_date", service.date)
    @content = @content.gsub(".link_show_page", client_service_url(client_id: service.client.id, id: service.id))

    mail(to: ba.account.email, subject: et.subject)
  end

  # def reminder_to_ba(ba_email, ba_name, date)
  # end

  def cancel_assignment_notification(data, company_name)
    ba = BrandAmbassador.find data["brand_ambassador_id"]
    lo = Location.find data["location_id"]
    et = EmailTemplate.find_by_name("cancel_assignment_notification")

    @content = et.content.gsub(".ba_name", ba.name).gsub(".service_company_name", company_name)
    @content = @content.gsub(".service_location", lo.complete_location).gsub(".service_date", data[:date])

    mail(to: ba.account.email, subject: et.subject)
  end

  def ba_unrespond_assignment(service)
    et = EmailTemplate.find_by_name("ba_unrespond_assignment")

    @content = et.content.gsub(".ba_name", service.brand_ambassador.name).gsub(".service_company_name", service.client.company_name)
    @content = @content.gsub(".service_location", service.location.complete_location).gsub(".service_complete_date", service.complete_date_time)
    @content = @content.gsub(".service_details", service.details).gsub(".project_link", client_service_url(client_id: service.client.id, id: service.id ))

    mail(to: "carol.wellins@gmail.com", subject: et.subject)
  end

  def send_ics(ba, service)
    mail(to: ba.account.email, subject: "Demo at #{service.client.company_name}, #{service.location.complete_location}") do |format|
       format.ics {
         ical = Icalendar::Calendar.new
         e = Icalendar::Event.new
         e.dtstart = service.start_at.utc
         e.dtend = service.end_at.utc
         e.summary = "#{service.client.company_name}, #{service.location.name}, #{ba.name}"
         e.description = <<-EOF
           Date: #{service.complete_date_time}
           Client: #{service.client.company_name}
           Location: #{service.location.complete_location}
           BA: #{ba.name}
           Details : #{service.details}
           Link: #{assignment_url(id: service.id)}
           Products: #{service.list_of_products}
         EOF
         e.url = assignment_url(id: service.id)
         ical.add_event(e)
         ical.publish
        render :text => ical.to_ical, :layout => false
      }
    end
  end

  def send_reminder_to_add_availablty_date(ba)
    et = EmailTemplate.find_by_name("send_reminder_to_add_availablty_date")
    @content = et.content.gsub(".ba_name", ba.name)
    mail(to: ba.account.email, cc: ["gregy@cx-iq.com"] , subject: et.subject)
  end

  def ba_is_paid(statement)
    et = EmailTemplate.find_by_name("ba_is_paid")
    data = open(statement.file.url)
    attachments["#{statement.file.filename}"] = data.read
    @content = et.content.gsub(".ba_name", statement.brand_ambassador.name)
    mail(to: statement.brand_ambassador.account.email, subject: et.subject)
  end

  def send_invoice(invoice)
    client = invoice.client
    emails = [client.email]
    unless client.additional_emails.nil?
      emails.push(client.additional_emails).flatten!
    end
    et = EmailTemplate.find_by_name("send_invoice")

    data = open(invoice.file.url)
    attachments["#{invoice.file.url.split("/").last}"] = data.read

    @content = et.content.gsub(".client_first_name", invoice.client.first_name)
    mail(to: "behtea@gmail.com", subject: et.subject)
  end

  def report_over_due_alert(service, admin = false)
    et = EmailTemplate.find_by_name("report_over_due_alert")
    if admin
      emails = ["gregy@cx-iq.com"]
    else
      emails = [service.brand_ambassador.account.email] << "gregy@cx-iq.com" # << User.all_ismp.collect{|a| a.email}
    end
    @content = et.content.gsub(".demo_date", service.complete_date_time).gsub(".service_company_name", service.client.company_name).gsub(".service_location", service.location.complete_location)
    mail(to: emails.flatten.uniq, subject: et.subject)
  end

  def thank_you_for_payment(invoice)
    et = EmailTemplate.find_by_name("thank_you_for_payment")

    emails = [invoice.client.email]
    invoice.client.additional_emails.split(";").each{|x| emails.push(x)}

    amount_received = number_to_currency(invoice.grand_total)
    amount_received = number_to_currency(invoice.amount_received) unless invoice.amount_received.nil?

    @content = et.content.gsub(".client_first_name", invoice.client.first_name).gsub(".amount_received", amount_received)
    mail(to: emails, subject: et.subject)
  end

  def inventory_confirmed_no(service, admin = false)
    et = EmailTemplate.find_by_name("inventory_confirmed_no")
    emails = ["gregy@cx-iq.com", "carol.wellins@gmail.com"]

    @content = et.content.gsub(".service_company_name", service.client.company_name)
    @content = @content.gsub(".service_location", service.location.complete_location).gsub(".service_complete_date", service.complete_date_time)
    @content = @content.gsub(".service_details", service.details).gsub(".project_link", client_service_url(client_id: service.client.id, id: service.id ))
    mail(to: emails.flatten.uniq, subject: et.subject)
  end

  def changes_on_your_services(service)
    et = EmailTemplate.find_by_name("changes_on_your_services")
    @content = et.content.gsub(".project_link", client_service_url(client_id: service.client.id, id: service.id ))
    mail(to: service.brand_ambassador.email, subject: et.subject)
  end

  def demo_request(service, log_id)
    log = Log.find log_id
    @content = log.data["email_log"]["content"]
    mail(
      from: 'schedule@flavorfanaticsism.com',
      to: service.location.email,
      # to: "location@contact.com",
      cc: "carolw@falvorfanaticsism.com",
      subject: log.data["email_log"]["subject"]
    )
  end

end
