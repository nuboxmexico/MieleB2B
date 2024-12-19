class CreateProductDiscounts < ActiveRecord::Migration[5.2]
  def change
    create_table :product_discounts do |t|
      t.integer :discount
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end
end
