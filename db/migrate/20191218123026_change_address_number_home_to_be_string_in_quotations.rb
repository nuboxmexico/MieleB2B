class ChangeAddressNumberHomeToBeStringInQuotations < ActiveRecord::Migration[5.2]
  def change
    change_column :quotations, :dispatch_address_number, :string
    change_column :quotations, :personal_address_number, :string
  end
end
