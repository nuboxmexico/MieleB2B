class AddSecondLastnameToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :second_lastname, :string
  end
end
