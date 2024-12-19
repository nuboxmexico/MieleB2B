class AddColumnsToQuotation < ActiveRecord::Migration[5.2]
  def change
    add_column :quotations, :name, :string
    add_column :quotations, :email, :string
    add_column :quotations, :rut, :string
    add_column :quotations, :phone, :integer
    add_column :quotations, :observations, :text
  end
end
