class CreateComparatorProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :comparator_products do |t|
      t.references :comparator, foreign_key: true
      t.references :product, foreign_key: true

      t.timestamps
    end
  end
end
