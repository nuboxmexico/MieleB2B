class AddDiscountToProduct < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :discount, :integer, default: 0
  end
end
