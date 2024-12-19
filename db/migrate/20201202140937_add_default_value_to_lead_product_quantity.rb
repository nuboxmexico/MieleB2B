class AddDefaultValueToLeadProductQuantity < ActiveRecord::Migration[5.2]
  def change
    change_column :lead_products, :quantity, :integer, default: 1
  end
end
