module ApplicationHelper
  def show_flash_message(name, msg)
    class_alert = "alert "
    case name
    when "notice"
      class_alert += "alert-success"
    when "error"
      class_alert += "alert-danger"
    when "alert"
      class_alert += "alert-info"
    end    

    content_tag :div, msg, class: class_alert, role: "alert"
  end

  def get_checkbox_available_date(date, day, ba)
    date_obj = Date.new(date[:year].to_i, date[:month].to_i, day)
    availables = ba.available_dates.where(availablty: date_obj)
    st_day, st_am, st_pm, hd_id, st_no_both = nil, nil, nil, nil, nil


    unless availables.blank?
      dt = availables.first
      st_day, st_am, st_pm, st_no_both = (dt.am || dt.pm ? true : false), dt.am, dt.pm, dt.no_both
      hd_id = hidden_field_tag("dates[]id", dt.id)
    end

    
    cb_day = check_box_tag("dates[]availablty", date_obj.strftime('%m/%d/%Y'), st_day, {class: "checkbox-avalaible checkbox-day"})
    cb_am = check_box_tag("dates[]am", nil, st_am, {class: "checkbox-avalaible checkbox-am"})
    cb_pm = check_box_tag("dates[]pm", nil, st_pm, {class: "checkbox-avalaible checkbox-pm"})    
    cb_no_both = check_box_tag("dates[]no_both", nil, st_no_both, {class: "checkbox-avalaible checkbox-noboth"})

    content_tag :tr, data: {date: date_obj.strftime('%m/%d/%Y')} do
      concat(hd_id)
      concat(content_tag(:td, date_obj.strftime('%m/%d/%Y')))
      concat(content_tag(:td, cb_day))
      concat(content_tag(:td, cb_am))
      concat(content_tag(:td, cb_pm))      
      concat(content_tag(:td, cb_no_both))
    end    
  end

  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "order-data #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link_to title, "#table-data", {:class => "order-data", data: {sort: column}}
  end  

  def number_to_words(number)
    words = ["zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "tweleve", "thirteen", "fourteen", "fifteen"]
    words[number]
  end

  def generate_demo_email_template(service)
    products_string = "<ul>"
    service.products.each{|x| products_string += "<li>#{x.name}</li>"}
    products_string += "</ul>"

    desirable_dates = "<ul>"
    desirable_dates += "<li>#{service.tbs_datetime("first_date", "start_at", "%m/%d/%I:%M %p")}</li>"
    desirable_dates += "<li>#{service.tbs_datetime("second_date", "start_at", "%m/%d/%I:%M %p")}</li>"
    desirable_dates += "</ul>"


    et = EmailTemplate.find_by_name("demo_request_template")
    et.subject.gsub!(".client_first_name", service.client.company_name)
    et.content.gsub!(".client_first_name", service.client.company_name)
    et.content.gsub!(".location_contact_name", service.location.name)
    et.content.gsub!(".desirable_dates", desirable_dates)
    et.content.gsub!(".products_name", products_string)
    et.content.gsub!(".ismp_name", "Carol Wellins")
    return et
  end
  
end