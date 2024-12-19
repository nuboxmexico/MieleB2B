class AddAvailableToCartItems < ActiveRecord::Migration[5.2]
  def change
    add_column :cart_items, :available, :boolean, default: true
  end
end
