# == Schema Information
#
# Table name: additional_personnels
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  client_id  :integer
#  account_id :integer
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class AdditionalPersonnel < ActiveRecord::Base
  belongs_to :user
  belongs_to :client
  belongs_to :account, :class_name => "User", :foreign_key => :account_id
  accepts_nested_attributes_for :account, allow_destroy: true

  def self.new_with_account(additional_personnel_params, user_id, client_id)
    additional_personnel = self.new(additional_personnel_params)
    additional_personnel.user_id = user_id
    additional_personnel.client_id = client_id
    additional_personnel.build_account(additional_personnel_params["account_attributes"])
    additional_personnel.account.add_role :additional_personnel
    return additional_personnel
  end

  def update_data(additional_personnel_params)
    if additional_personnel_params["account_attributes"]["password"].blank?
      additional_personnel_params["account_attributes"].delete("password")
      additional_personnel_params["account_attributes"].delete("password_confirmation")
    end
    self.update_attributes(additional_personnel_params)
  end

end
