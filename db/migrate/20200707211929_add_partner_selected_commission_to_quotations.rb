class AddPartnerSelectedCommissionToQuotations < ActiveRecord::Migration[5.2]
	def change
		change_table(:quotations) do |t|
			t.references :partner_selected_commission, foreign_key: { to_table: 'miele_roles' }
		end
	end
end
