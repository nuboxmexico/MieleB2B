class ChangeNameInQuotations < ActiveRecord::Migration[5.2]
	def change
		rename_column :quotations, :dispath_dpto_number, :dispatch_dpto_number
	end
end
