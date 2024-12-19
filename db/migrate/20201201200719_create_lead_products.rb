class CreateLeadProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :lead_products do |t|
      t.string :sku
      t.string :name
      t.integer :quantity
      t.integer :unit_price
      t.references :lead, foreign_key: true

      t.timestamps
    end
  end
end
