class AddFieldsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :lastname, :string
    add_column :users, :shop, :string
    add_column :users, :cost_center, :string
    add_column :users, :phone, :string
    add_column :users, :workday, :string
  end
end
