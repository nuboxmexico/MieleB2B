class FixDiscountCheckout < ActiveRecord::Migration[5.2]
	def self.up
		change_column :product_discounts, :discount, :decimal
		change_column :cart_items, :discount_percent, :decimal
		change_column :quotation_products, :discount_percent, :decimal
	end
	def self.down
		change_column :product_discounts, :discount, :integer
		change_column :cart_items, :discount_percent, :integer
		change_column :quotation_products, :discount_percent, :integer
	end
end
