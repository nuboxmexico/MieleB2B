class FixFieldsCheckout < ActiveRecord::Migration[5.2]
	def change
		remove_column :cart_items, :discount
		remove_column :quotation_products, :discount
		add_column :cart_items, :discount, :integer, default: 0
		add_column :quotation_products, :discount, :integer, default: 0
		add_column :cart_items, :discount_type, :string
		add_column :quotation_products, :discount_type, :string
	end
end
