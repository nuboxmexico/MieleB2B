class AddPreferentialCustomerToQuotations < ActiveRecord::Migration[5.2]
  def change
    add_column :quotations, :preferential_customer, :boolean, default: false
  end
end
