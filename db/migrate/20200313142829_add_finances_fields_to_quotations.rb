class AddFinancesFieldsToQuotations < ActiveRecord::Migration[5.2]
  def change
    add_column :quotations, :so_code, :string
    add_column :quotations, :paid_ammount, :integer, default: 0
  end
end
