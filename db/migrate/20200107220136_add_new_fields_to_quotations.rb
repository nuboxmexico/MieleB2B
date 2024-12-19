class AddNewFieldsToQuotations < ActiveRecord::Migration[5.2]
  def change
    add_column :quotations, :business_rut, :string
    add_column :quotations, :business_name, :string
  end
end
