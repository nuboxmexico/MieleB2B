class AddMultipleAddressStreetTypeToQuotations < ActiveRecord::Migration[5.2]
  def change
    add_column :quotations, :billing_address_street_type, :string
    add_column :quotations, :dispatch_address_street_type, :string
    add_column :quotations, :personal_address_street_type, :string
    add_column :quotations, :instalation_address_street_type, :string
  end
end
