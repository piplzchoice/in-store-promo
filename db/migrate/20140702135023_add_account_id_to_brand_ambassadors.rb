class AddAccountIdToBrandAmbassadors < ActiveRecord::Migration
  def change
    add_column :brand_ambassadors, :account_id, :integer
  end
end
