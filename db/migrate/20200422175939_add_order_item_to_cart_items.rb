class AddOrderItemToCartItems < ActiveRecord::Migration[5.2]
  def change
    add_column :cart_items, :order_item, :integer, default: 0
  end
end
