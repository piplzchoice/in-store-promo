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
  
end
