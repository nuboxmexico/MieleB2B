class AddCustomerProjectToCustomers < ActiveRecord::Migration[5.2]
  def change
    add_column :customers, :customer_project, :boolean
  end
end
