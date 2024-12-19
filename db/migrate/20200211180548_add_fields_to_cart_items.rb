class AddFieldsToCartItems < ActiveRecord::Migration[5.2]
  def change
    add_column :cart_items, :discount, :boolean
    add_column :cart_items, :price, :float
  end
end
