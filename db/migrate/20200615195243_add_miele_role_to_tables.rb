class AddMieleRoleToTables < ActiveRecord::Migration[5.2]
  def change
  	add_reference :quotations, :miele_role, foreign_key: true
  	add_reference :users, :miele_role, foreign_key: true
  end
end
