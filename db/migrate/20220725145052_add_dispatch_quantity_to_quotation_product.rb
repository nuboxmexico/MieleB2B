class AddDispatchQuantityToQuotationProduct < ActiveRecord::Migration[5.2]
  def change
    add_column :quotation_products, :dispatch_quantity, :integer, default: 0
  end
end
