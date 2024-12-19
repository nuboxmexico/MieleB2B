class AddProfitCenterCheckout < ActiveRecord::Migration[5.2]
	def change
		add_column :cart_items, :profit_center, :boolean, default: true
		add_column :quotation_products, :profit_center, :boolean, default: true
	end
end
