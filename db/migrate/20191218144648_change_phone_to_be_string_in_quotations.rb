class ChangePhoneToBeStringInQuotations < ActiveRecord::Migration[5.2]
  def change
    change_column :quotations, :phone, :string
  end
end
