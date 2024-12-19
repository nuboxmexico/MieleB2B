class AddDeletedAtToMieleRoles < ActiveRecord::Migration[5.2]
	def change
		add_column :miele_roles, :deleted_at, :datetime
		add_index :miele_roles, :deleted_at
	end
end
