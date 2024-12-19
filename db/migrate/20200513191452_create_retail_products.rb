class CreateRetailProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :retail_products do |t|
      t.references :product, foreign_key: true
      t.references :retail, foreign_key: true
      t.string :tnr

      t.timestamps
    end
  end
end
