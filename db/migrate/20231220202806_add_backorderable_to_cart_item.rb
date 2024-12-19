class AddBackorderableToCartItem < ActiveRecord::Migration[5.2]
  def change
    add_column :cart_items, :backorderable, :boolean, default: false
  end
end
