class AddReferredUserToQuotations < ActiveRecord::Migration[5.2]
	def change
		change_table(:quotations) do |t|
			t.references :referred_user, foreign_key: { to_table: 'users' }
		end
	end
end
