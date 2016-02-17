# == Schema Information
#
# Table name: logs
#
#  id         :integer          not null, primary key
#  service_id :integer
#  created_at :datetime
#  updated_at :datetime
#  user_id    :integer
#  category   :integer
#  data       :text
#

class Log < ActiveRecord::Base
  belongs_to :service
  belongs_to :user
  # validates :origin, :latest, presence: true
  serialize :data, JSON
  enum category: [ :status_changed, :modified_details, :modified_main, :coop_added, :inventory_comment ]
  default_scope { order('created_at ASC') }

  def self.create_data(service_id, origin, latest)
    log = self.new
    log.service_id = service_id
    log.origin = origin
    log.latest = latest
    log.save
  end

  def self.record_status_changed(service_id, origin, latest, current_user_id)
    log = self.new
    log.category = :status_changed
    log.service_id = service_id
    log.user_id = current_user_id
    log.data = {origin: origin, latest: latest}
    log.save
  end

  def self.record_modified_details(service_id, old_data, new_data, current_user_id)
    log = self.new
    log.category = :modified_details
    log.service_id = service_id
    log.user_id = current_user_id
    log.data = {old: old_data, new: new_data}
    log.save
  end

  def self.record_modified_main(service_id, old_data, new_data, latest, current_user_id)
    log = self.new
    log.category = :modified_main
    log.service_id = service_id
    log.user_id = current_user_id
    log.data = {old: old_data, new: new_data, origin: old_data["status"], latest: latest}
    log.save
  end

  def self.record_coop_added(service_id, co_op_client_id, current_user_id)
    log = self.new
    log.category = :coop_added
    log.service_id = service_id
    log.user_id = current_user_id
    log.data = {co_op_client_id: co_op_client_id}
    log.save
  end

  def self.record_comment_of_inventory(service_id, comments, current_user_id)
    log = self.new
    log.category = :inventory_comment
    log.service_id = service_id
    log.user_id = current_user_id
    log.data = {comments: comments}
    log.save
  end

  def what
    case category
    when "status_changed"
      if data["origin"] == 0 && data["latest"] == 1
        "record created"
      else
        "update"
      end
    when "modified_main"
      "record updated"
    when "modified_details"
      "record updated"
    when "coop_added"
      "add coop client"
    when "inventory_comment"
      "comment"
    end
  end

  def status
    case category
    when "status_changed"
      Service.get_status data["latest"]
    when "modified_main"
      Service.get_status data["latest"]
    when "modified_details"
      "-"
    when "coop_added"
      "-"
    when "inventory_comment"
      "-"
    else
      "update"
    end
  end

  def comments
    changes = []

    case category
    when "status_changed"
      if data["latest"].to_i == 11
        "Confirmed date: <b>#{service.inventory_date.strftime('%m/%d/%Y')}</b>; Confirmed by: <b>#{service.inventory_confirmed}</b>"
      else
        "-"
      end
    when "modified_main"
      unless data["old"]["location_id"].to_i == data["new"]["location_id"].to_i
        changes <<  "Location changed to <b>#{Location.find(data["new"]["location_id"].to_i).name}</b>"
      end

      unless data["old"]["brand_ambassador_id"].to_i == data["new"]["brand_ambassador_id"].to_i
        changes << "BA changed to <b>#{BrandAmbassador.find(data["new"]["brand_ambassador_id"].to_i).name}</b>"
      end

      unless data["old"]["start_at"] == data["new"]["start_at"]
        start_at = DateTime.parse(data["new"]["start_at"]).strftime("%m/%d/%Y - %I:%M %p")
        end_at = DateTime.parse(data["new"]["end_at"]).strftime("%I:%M %p")
        changes << "Re-Scheduled to <b>#{start_at} / #{end_at}</b>"
      end
    when "modified_details"
      unless data["old"]["details"] == data["new"]["details"]
        changes <<  "Details changed: <b>#{data["new"]["details"]}</b>"
      end

      unless data["old"]["product_ids"] == data["new"]["product_ids"]
        old_ids = data["old"]["product_ids"].map{|x| x.to_i}
        new_ids = data["new"]["product_ids"].map{|x| x.to_i}

        diff_ids = old_ids + new_ids - (old_ids & new_ids)

        diff_ids.each do |id|
          name = Product.find(id).name

          if !old_ids.include?(id) && new_ids.include?(id)
            changes <<  "Add product <b>#{name}</b>"
          elsif old_ids.include?(id) && !new_ids.include?(id)
            changes <<  "Remove product <b>#{name}</b>"
          end
        end

      end

    when "coop_added"
      changes << "Added coop client: <b>#{Client.find(data["co_op_client_id"]).name}</b>"
    when "inventory_comment"
      changes << "#{data["comments"]}"
    else
      "-"
    end

    changes.join("; ")
  end

end
