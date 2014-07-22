class CreateEmailTemplates < ActiveRecord::Migration
  def change
    create_table :email_templates do |t|
      t.string :name
      t.string :subject
      t.text :content      
      t.timestamps
    end
  end
end
