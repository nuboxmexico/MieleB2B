class AddProductToProductImages < ActiveRecord::Migration[5.2]
  def change
    add_reference :product_images, :product, foreign_key: true
  end
end
