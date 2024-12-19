class AddApplyDiscountToCheckout < ActiveRecord::Migration[5.2]
  def change
  	add_column :carts, :apply_discount, :boolean, default: false
  	add_column :quotations, :apply_discount, :boolean, default: false
  end
end
