class AddProductToProductDiscounts < ActiveRecord::Migration[5.2]
  def change
    add_reference :product_discounts, :product, foreign_key: true
  end
end
