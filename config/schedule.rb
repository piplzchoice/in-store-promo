# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

every :hour do
  rake "notification:unrespond_service"
end

every 1.day, :at => '01:00 am' do
  rake "notification:add_availblty_date"
end

# every 10.minutes do
#   rake "notification:change_to_conduceted"
# end

every :day, :at => '01:00am' do
  rake "notification:report_over_due_alert"
end

every :day, :at => '01:00am' do
  rake "notification:report_over_due_alert_admin"
end

# Learn more: http://github.com/javan/whenever


# rake notification:unrespond_service
# hourly

# rake notification:add_availblty_date
# daily

# rake notification:change_to_conduceted
# 10 minutes

# rake notification:report_over_due_alert
# daily

# rake notification:report_over_due_alert_admin
# daily

