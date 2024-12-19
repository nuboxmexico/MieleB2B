class CreateProductFamilies < ActiveRecord::Migration[5.2]
  def change
    create_table :product_families do |t|
      t.references :product, foreign_key: true
      t.references :family, foreign_key: true

      t.timestamps
    end
  end
end
