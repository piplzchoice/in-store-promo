# == Schema Information
#
# Table name: email_templates
#
#  id         :integer          not null, primary key
#  for        :string(255)
#  subject    :string(255)
#  content    :text
#  created_at :datetime
#  updated_at :datetime
#

class EmailTemplate < ActiveRecord::Base
  validates :name, :subject, :content, presence: true

  def name_template
    name.split("_").join(" ").titleize
  end
end


