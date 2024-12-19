class AddOrderItemToQuotationProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :quotation_products, :order_item, :integer, default: 0
    add_reference :quotation_products, :instalation, foreign_key: true
  end
end
