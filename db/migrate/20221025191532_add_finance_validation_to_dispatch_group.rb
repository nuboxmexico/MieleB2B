class AddFinanceValidationToDispatchGroup < ActiveRecord::Migration[5.2]
  def change
    add_column :dispatch_groups, :finance_validation, :boolean, default: false
  end
end
