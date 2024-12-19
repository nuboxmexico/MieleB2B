class AddDiscountToQuotationProduct < ActiveRecord::Migration[5.2]
  def change
    add_column :quotation_products, :discount, :integer, default: 0
  end
end
