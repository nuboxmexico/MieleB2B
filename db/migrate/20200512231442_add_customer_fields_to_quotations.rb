class AddCustomerFieldsToQuotations < ActiveRecord::Migration[5.2]
  def change
    add_column :quotations, :lastname, :string
    add_column :quotations, :second_lastname, :string
    add_column :quotations, :project_name, :string
  end
end
