class AddProjectFieldsToQuotations < ActiveRecord::Migration[5.2]
  def change
    add_column :quotations, :currency, :string
    add_column :quotations, :correlative, :string
  end
end
