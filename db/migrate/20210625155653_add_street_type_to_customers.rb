class AddStreetTypeToCustomers < ActiveRecord::Migration[5.2]
  def change
    add_column :customers, :billing_address_street_type, :string
    add_column :customers, :dispatch_address_street_type, :string
    add_column :customers, :personal_address_street_type, :string
    add_column :customers, :instalation_address_street_type, :string
  end
end
