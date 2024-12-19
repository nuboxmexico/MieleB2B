class AddFinanceValidationToPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :payments, :finance_validation, :boolean, default: false
  end
end
