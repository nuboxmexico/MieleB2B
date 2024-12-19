class AddAddressFieldsToQuotations < ActiveRecord::Migration[5.2]
	def change
		add_column :quotations, :billing_address, :string
		add_column :quotations, :billing_address_number, :integer
		add_column :quotations, :billing_dpto_number, :integer
		add_column :quotations, :instalation_address, :string
		add_column :quotations, :instalation_address_number, :integer
		add_column :quotations, :instalation_dpto_number, :integer

		change_table(:quotations) do |t|
			t.references :instalation_commune, foreign_key: { to_table: 'communes' }
			t.references :billing_commune, foreign_key: { to_table: 'communes' }
		end
	end
end
