class CreateQuotationProductsAuxes < ActiveRecord::Migration[5.2]
  def change
    create_table :quotation_products_auxes do |t|
      t.references :product, foreign_key: true
      t.references :dispatch_group, foreign_key: true
      t.integer :quantity
      t.string :name
      t.string :sku
      t.timestamps
    end
  end
end
