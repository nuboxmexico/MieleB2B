class ChangeDefaultActivationConfirmFromQuotations < ActiveRecord::Migration[5.2]
	def up
		change_column_default :quotations, :activation_confirm, false
	end

	def down
		change_column_default :quotations, :activation_confirm, true
	end
end
