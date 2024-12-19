class CreateCustomers < ActiveRecord::Migration[5.2]
  def change
    create_table :customers do |t|
      t.string :name
      t.string :lastname
      t.string :second_lastname
      t.string :email
      t.string :phone
      t.string :rut
      t.string :dispatch_address
      t.string :dispatch_address_number
      t.string :dispatch_dpto_number
      t.string :personal_address
      t.string :personal_address_number
      t.string :personal_dpto_number
      t.string :business_rut
      t.string :business_name
      t.string :business_sector
      t.string :billing_address
      t.string :billing_address_number
      t.string :billing_dpto_number
      t.string :instalation_address
      t.string :instalation_address_number
      t.string :instalation_dpto_number
      t.references :dispatch_commune, foreign_key: { to_table: 'communes' }
      t.references :personal_commune, foreign_key: { to_table: 'communes' }
      t.references :instalation_commune, foreign_key: { to_table: 'communes' }
      t.references :billing_commune, foreign_key: { to_table: 'communes' }

      t.timestamps
    end
  end
end
