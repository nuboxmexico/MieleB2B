class CreateQuotationProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :quotation_products do |t|
      t.references :quotation, foreign_key: true
      t.references :product, foreign_key: true
      t.string :name
      t.integer :price
      t.integer :quantity, default: 1
      t.string :sku
      t.boolean :mandatory, default: false
      t.boolean :dispatch, default: false

      t.timestamps
    end
  end
end
