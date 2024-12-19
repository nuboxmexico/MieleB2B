class AddOcValidationToQuotations < ActiveRecord::Migration[5.2]
  def change
    add_column :quotations, :oc_validation, :string
  end
end
