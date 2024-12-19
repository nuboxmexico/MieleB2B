class AddDptoNumbersToQuotation < ActiveRecord::Migration[5.2]
  def change
    add_column :quotations, :dispath_dpto_number, :integer
    add_column :quotations, :personal_dpto_number, :integer
  end
end
