class AddDataAddressToQuotation < ActiveRecord::Migration[5.2]
  def change
    add_column :quotations, :dispatch_address, :string
    add_column :quotations, :dispatch_address_number, :integer
    add_column :quotations, :personal_address, :string
    add_column :quotations, :personal_address_number, :integer
  end
end
