class AddIsPriceUfToCartItems < ActiveRecord::Migration[5.2]
  def change
    add_column :cart_items, :is_price_UF, :boolean
  end
end
