class AddRateProjects < ActiveRecord::Migration
  def change
    add_column :projects, :rate, :decimal, :precision => 8, :scale => 2
  end
end
