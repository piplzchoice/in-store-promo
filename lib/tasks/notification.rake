namespace :notification do
  desc "Send admin to unrespond service after 12 hours creation"
  task :unrespond_service => :environment do
    current_time = Time.now.to_time
    Service.where("status = ?", 1).each do |service|
      if TimeDifference.between(service.created_at.to_time, current_time).in_hours > Service.send_notif_after
        service.update_attributes({status: Service.status_unrespond, token: Devise.friendly_token})
        ApplicationMailer.ba_unrespond_assignment(service).deliver!
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
      BrandAmbassador.all.each do |ba|
        ApplicationMailer.send_reminder_to_add_availablty_date(ba).deliver!
      end
    end
  end  
  
end
