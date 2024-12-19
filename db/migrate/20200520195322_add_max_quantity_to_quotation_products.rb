class AddMaxQuantityToQuotationProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :quotation_products, :max_quantity, :integer
  end
end
