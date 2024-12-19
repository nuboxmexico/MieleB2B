class AddBstockToCartItems < ActiveRecord::Migration[5.2]
  def change
    add_column :carts, :bstock, :boolean, default: false
  end
end
