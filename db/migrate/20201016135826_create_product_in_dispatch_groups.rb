class CreateProductInDispatchGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :product_in_dispatch_groups do |t|
      t.references :dispatch_group, foreign_key: true
      t.references :product, foreign_key: true
      t.integer :quantity

      t.timestamps
    end
  end
end
