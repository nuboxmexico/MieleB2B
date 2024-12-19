class AddIsPaiToCheckout < ActiveRecord::Migration[5.2]
	def change
		add_column :cart_items, :is_pai, :boolean, default: false
		add_column :quotation_products, :is_pai, :boolean, default: false
	end
end
