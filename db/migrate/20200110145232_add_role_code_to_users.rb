class AddRoleCodeToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :role_code, :string
  end
end
