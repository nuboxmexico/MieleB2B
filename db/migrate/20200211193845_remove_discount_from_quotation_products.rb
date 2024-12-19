class RemoveDiscountFromQuotationProducts < ActiveRecord::Migration[5.2]
  def change
  	remove_column :quotation_products, :discount
  end
end
