class AddFieldsToCustomers < ActiveRecord::Migration[5.2]
	def change
		add_reference :customers, :user, foreign_key: true
		add_reference :customers, :quotation, foreign_key: true
		add_column :customers, :expiration_date, :date
	end
end
