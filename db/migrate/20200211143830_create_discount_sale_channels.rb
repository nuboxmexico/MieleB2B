class CreateDiscountSaleChannels < ActiveRecord::Migration[5.2]
  def change
    create_table :discount_sale_channels do |t|
      t.references :product_discount, foreign_key: true
      t.references :sale_channel, foreign_key: true

      t.timestamps
    end
  end
end
