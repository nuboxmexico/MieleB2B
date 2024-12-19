class AddMovilePhoneToCustomer < ActiveRecord::Migration[5.2]
  def change
    add_column :customers, :mobile_phone, :string
  end
end
