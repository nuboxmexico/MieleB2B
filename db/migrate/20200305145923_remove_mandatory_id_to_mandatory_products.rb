class RemoveMandatoryIdToMandatoryProducts < ActiveRecord::Migration[5.2]
	def change
		remove_column :mandatory_products, :mandatory_id
		add_reference :mandatory_products, :instalation, foreign_key: true
	end
end
