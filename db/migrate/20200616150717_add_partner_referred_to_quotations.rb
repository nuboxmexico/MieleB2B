class AddPartnerReferredToQuotations < ActiveRecord::Migration[5.2]
	def change
		change_table(:quotations) do |t|
			t.references :partner_referred, foreign_key: { to_table: 'miele_roles' }
		end
	end
end
