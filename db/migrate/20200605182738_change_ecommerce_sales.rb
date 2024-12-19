class ChangeEcommerceSales < ActiveRecord::Migration[5.2]
  def change
  	drop_table :ecommerce_products
  	add_reference :quotation_products, :ecommerce_sale, foreign_key: true
  end
end
