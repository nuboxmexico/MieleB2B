class AddPaymentTypeToPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :payments, :payment_type, :string
  end
end
