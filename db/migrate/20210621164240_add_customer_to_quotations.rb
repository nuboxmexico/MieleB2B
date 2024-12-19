class AddCustomerToQuotations < ActiveRecord::Migration[5.2]
  def change
    add_reference :quotations, :customer, foreign_key: true
  end
end
