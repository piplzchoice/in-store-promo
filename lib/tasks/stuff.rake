namespace :stuff do
  desc "Modified value of report"
  task :formula_report_change => :environment do
    Report.all.each do |report|

      unless report.product_one.nil?
        unless report.product_one_beginning.nil? && report.product_one_end.nil? && report.product_one_sample.nil?
          report.product_one_beginning = report.product_one_beginning.nil? ? 0 : report.product_one_beginning
          report.product_one_end = report.product_one_end.nil? ? 0 : report.product_one_end
          report.product_one_sample = report.product_one_sample.nil? ? 0 : report.product_one_sample
          report.product_one_sold = report.product_one_beginning - report.product_one_end - report.product_one_sample
        end
      end

      unless report.product_two.nil?
        unless report.product_two_beginning.nil? && report.product_two_end.nil? && report.product_two_sample.nil?
          report.product_two_beginning = report.product_two_beginning.nil? ? 0 : report.product_two_beginning
          report.product_two_end = report.product_two_end.nil? ? 0 : report.product_two_end
          report.product_two_sample = report.product_two_sample.nil? ? 0 : report.product_two_sample          
          report.product_two_sold = report.product_two_beginning - report.product_two_end - report.product_two_sample
        end
      end

      unless report.product_three.nil?
        unless report.product_three_beginning.nil? && report.product_three_end.nil? && report.product_three_sample.nil?
          report.product_three_beginning = report.product_three_beginning.nil? ? 0 : report.product_three_beginning
          report.product_three_end = report.product_three_end.nil? ? 0 : report.product_three_end
          report.product_three_sample = report.product_three_sample.nil? ? 0 : report.product_three_sample          
          report.product_three_sold = report.product_three_beginning - report.product_three_end - report.product_three_sample
        end
      end

      unless report.product_four.nil?
        unless report.product_four_beginning.nil? && report.product_four_end.nil? && report.product_four_sample.nil?
          report.product_four_beginning = report.product_four_beginning.nil? ? 0 : report.product_four_beginning
          report.product_four_end = report.product_four_end.nil? ? 0 : report.product_four_end
          report.product_four_sample = report.product_four_sample.nil? ? 0 : report.product_four_sample          
          report.product_four_sold = report.product_four_beginning - report.product_four_end - report.product_four_sample
        end
      end

      unless report.product_five.nil?
        unless report.product_five_beginning.nil? && report.product_five_end.nil? && report.product_five_sample.nil?
          report.product_five_beginning = report.product_five_beginning.nil? ? 0 : report.product_five_beginning
          report.product_five_end = report.product_five_end.nil? ? 0 : report.product_five_end
          report.product_five_sample = report.product_five_sample.nil? ? 0 : report.product_five_sample          
          report.product_five_sold = report.product_five_beginning - report.product_five_end - report.product_five_sample
        end
      end

      unless report.product_six.nil?
        unless report.product_six_beginning.nil? && report.product_six_end.nil? && report.product_six_sample.nil?
          report.product_six_beginning = report.product_six_beginning.nil? ? 0 : report.product_six_beginning
          report.product_six_end = report.product_six_end.nil? ? 0 : report.product_six_end
          report.product_six_sample = report.product_six_sample.nil? ? 0 : report.product_six_sample          
          report.product_six_sold = report.product_six_beginning - report.product_six_end - report.product_six_sample
        end
      end

      report.save

    end
  end  
  
  desc "Update all user password to default"
  task :update_users_password => :environment do
    User.all.each do |user|
      user.update_attributes({password: "1q2w3e4r5t", password_confirmation: "1q2w3e4r5t"})
    end
  end  

end