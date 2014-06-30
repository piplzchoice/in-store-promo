class CreateClients < ActiveRecord::Migration
  def change
    create_table :clients do |t|
      t.integer :user_id
      t.string :company_name
      t.string :title
      t.string :first_name
      t.string :last_name
      t.string :phone
      t.string :street_one
      t.string :street_two
      t.string :city
      t.string :state
      t.string :zipcode
      t.string :country
      t.string :billing_name
      t.timestamps
    end
  end
end
