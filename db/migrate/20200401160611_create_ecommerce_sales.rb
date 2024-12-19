class CreateEcommerceSales < ActiveRecord::Migration[5.2]
  def change
    create_table :ecommerce_sales do |t|
      t.datetime :selled_at
      t.references :commune, foreign_key: true
      t.integer :total
      t.string :order_code

      t.timestamps
    end
  end
end
