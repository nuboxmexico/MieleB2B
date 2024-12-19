class ChangeAddressNumberToBeStringInQuotations < ActiveRecord::Migration[5.2]
  def change
    change_column :quotations, :dispath_dpto_number, :string
    change_column :quotations, :personal_dpto_number, :string
  end
end
