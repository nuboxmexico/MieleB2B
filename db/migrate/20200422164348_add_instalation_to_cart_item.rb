class AddInstalationToCartItem < ActiveRecord::Migration[5.2]
  def change
    add_reference :cart_items, :instalation, foreign_key: true
  end
end
