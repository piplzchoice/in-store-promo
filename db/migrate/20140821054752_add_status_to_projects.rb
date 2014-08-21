class AddStatusToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :status, :integer, :default => 1
  end
end
