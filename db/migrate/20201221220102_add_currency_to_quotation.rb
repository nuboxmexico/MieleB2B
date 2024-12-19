class AddCurrencyToQuotation < ActiveRecord::Migration[5.2]
  def change
    remove_column :quotations, :currency
    add_column :quotations, :currency, :integer, default: 1 # CLP por defecto
  end
end
