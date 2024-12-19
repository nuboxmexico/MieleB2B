class CreateEcommerceProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :ecommerce_products do |t|
      t.references :ecommerce_sale, foreign_key: true
      t.references :product, foreign_key: true
      t.integer :quantity
      t.integer :total

      t.timestamps
    end
  end
end
