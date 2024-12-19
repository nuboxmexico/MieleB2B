class AddBackorderableToQuotationProduct < ActiveRecord::Migration[5.2]
  def change
    add_column :quotation_products, :backorderable, :boolean, default: false
  end
end
