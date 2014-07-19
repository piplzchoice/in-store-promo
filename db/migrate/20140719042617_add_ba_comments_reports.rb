class AddBaCommentsReports < ActiveRecord::Migration
  def change
    add_column :reports, :ba_comments, :text
  end
end