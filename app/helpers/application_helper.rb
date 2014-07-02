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
end
