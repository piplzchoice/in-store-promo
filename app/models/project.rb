# == Schema Information
#
# Table name: projects
#
#  id           :integer          not null, primary key
#  user_id      :integer
#  client_id    :integer
#  name         :string(255)
#  descriptions :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#

class Project < ActiveRecord::Base
  belongs_to :user
  belongs_to :client
end
