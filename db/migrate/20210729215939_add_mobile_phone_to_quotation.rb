class AddMobilePhoneToQuotation < ActiveRecord::Migration[5.2]
  def change
    add_column :quotations, :mobile_phone, :string
  end
end
