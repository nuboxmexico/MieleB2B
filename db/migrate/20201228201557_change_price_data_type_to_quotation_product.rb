class ChangePriceDataTypeToQuotationProduct < ActiveRecord::Migration[5.2]
  def change
    change_column :quotation_products, :price, :float
  end
end
