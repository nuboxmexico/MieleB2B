class AddDefaultValueToProductInDispatchQuantity < ActiveRecord::Migration[5.2]
  def change
    change_column :product_in_dispatch_groups, :quantity, :integer, default: 0
  end
end
