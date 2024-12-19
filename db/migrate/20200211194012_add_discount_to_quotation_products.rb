class AddDiscountToQuotationProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :quotation_products, :discount, :boolean, default: false
  end
end
