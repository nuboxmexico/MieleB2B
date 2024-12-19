class CreateProductInUnitRealStates < ActiveRecord::Migration[5.2]
  def change
    create_table :product_in_unit_real_states do |t|
      t.string :name
      t.string :sku
      t.integer :quantity
      t.references :quotation_product, foreign_key: true
      t.references :config_unit_real_state, foreign_key: true

      t.timestamps
    end
  end
end
