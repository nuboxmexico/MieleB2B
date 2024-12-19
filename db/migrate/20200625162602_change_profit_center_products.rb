class ChangeProfitCenterProducts < ActiveRecord::Migration[5.2]
	def change
		change_column :products, :profit_center, "boolean USING CAST(profit_center AS boolean)", default: true
	end
end
