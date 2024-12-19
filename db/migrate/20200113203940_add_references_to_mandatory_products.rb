class AddReferencesToMandatoryProducts < ActiveRecord::Migration[5.2]
	def change
		add_column :mandatory_products, :product_id, :bigint
		add_index :mandatory_products, :product_id
		add_column :mandatory_products, :mandatory_id, :bigint
		add_index :mandatory_products, :mandatory_id
	end
end
