class AddCompanyAndFunctionFieldToPersonnels < ActiveRecord::Migration
  def change
    add_column :additional_personnels, :company, :text
    add_column :additional_personnels, :function_text, :text
  end
end
