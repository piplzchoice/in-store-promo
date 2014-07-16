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
    st_day, st_am, st_pm, hd_id = nil, nil, nil, nil


    unless availables.blank?
      dt = availables.first
      st_day, st_am, st_pm = (dt.am || dt.pm ? true : false), dt.am, dt.pm
      hd_id = hidden_field_tag("dates[]id", dt.id)
    end

    
    cb_day = check_box_tag("dates[]availablty", date_obj.strftime('%m/%d/%Y'), st_day, {class: "checkbox-avalaible checkbox-day"})
    cb_am = check_box_tag("dates[]am", nil, st_am, {class: "checkbox-avalaible checkbox-am"})
    cb_pm = check_box_tag("dates[]pm", nil, st_pm, {class: "checkbox-avalaible checkbox-pm"})    

    content_tag :tr, data: {date: date_obj.strftime('%m/%d/%Y')} do
      concat(hd_id)
      concat(content_tag(:td, date_obj.strftime('%m/%d/%Y')))
      concat(content_tag(:td, cb_day))
      concat(content_tag(:td, cb_am))
      concat(content_tag(:td, cb_pm))      
    end    
  end
end