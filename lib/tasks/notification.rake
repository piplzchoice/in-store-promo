namespace :notification do
  desc "Send admin to unrespond service after 12 or custom hours creation"
  task :unrespond_service => :environment do
    current_time = Time.now.to_time
    Service.where("status = ?", 1).each do |service|
      if TimeDifference.between(service.updated_at.to_time, current_time).in_hours > DefaultValue.send_unrespond.round
        service.update_attributes({status: Service.status_unrespond, token: Devise.friendly_token})
        ApplicationMailer.ba_unrespond_assignment(service.id).deliver
      end
    end    
  end  

  desc "Set scheduled service to Conducted"
  task :change_to_conduceted => :environment do
    current_time = Time.now.to_time
    Service.where("status = ?", 1).each do |service|
      if current_time > service.start_at.to_time
        service.update_attributes({status: Service.status_conducted, token: Devise.friendly_token})
      end
    end    
  end  

  desc "Notified BA to add their availablty date"
  task :add_availblty_date => :environment do
    current_time = Time.now.to_time
    if current_time.strftime("%d") == "15"
      BrandAmbassador.with_status_active.each do |ba|
        if ba.account.is_active
          ApplicationMailer.send_reminder_to_add_availablty_date(ba.id).deliver
        end
      end
    end
  end  

  desc "Send BA and ISMP when a service report is not created by the BA 36 hours after the service was completed / conducted"
  task :report_over_due_alert => :environment do
    current_time = Time.now.to_time
    Service.where("status = ?", 4).each do |service|
      if TimeDifference.between(service.updated_at.to_time, current_time).in_hours > 36.round
        service.update_attributes({alert_sent: true, alert_sent_date: 35.hours.from_now.to_time})
        if service.brand_ambassador.account.is_active
          ApplicationMailer.report_over_due_alert(service.id).deliver
        end
      end
    end    
  end  

  desc "Send the copy of the alert to Admin when the report is not created 12 hours after the initial alert was sent"
  task :report_over_due_alert_admin => :environment do
    current_time = Time.now.to_time
    Service.where("status = ? AND alert_sent = ? AND alert_sent_admin = ?", 4, true, false).each do |service|
      if TimeDifference.between(service.alert_sent_date.to_time, current_time).in_hours > 12.round
        service.update_attributes({alert_sent_admin: true, alert_sent_admin_date: current_time})
        if service.brand_ambassador.account.is_active
          ApplicationMailer.report_over_due_alert(service.id, true).deliver
        end
      end
    end    
  end  

  desc "check for inventory confirmed"
  task :check_inventory_is_cofirmed => :environment do
    current_time = Time.now.to_time
    Service.where({status: [2, 11], is_old_service: false}).each do |service|
      if TimeDifference.between(service.start_at.to_time, current_time).in_hours > 96.round
        unless service.inventory_confirm
          ApplicationMailer.inventory_confirmed_no(service.id).deliver
        end
      end
    end    
  end    
  
end
