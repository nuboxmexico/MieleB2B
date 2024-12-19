class AddDiscountPercent < ActiveRecord::Migration[5.2]
	def change
		add_column :cart_items, :discount_percent, :integer, default: 0
		add_column :quotation_products, :discount_percent, :integer, default: 0
	end
end
