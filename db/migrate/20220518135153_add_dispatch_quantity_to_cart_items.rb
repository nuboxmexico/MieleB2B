class AddDispatchQuantityToCartItems < ActiveRecord::Migration[5.2]
  def change
    add_column :cart_items, :dispatch_quantity, :integer, default: 0
  end
end
