class AddQuotationIdToEcommerceSale < ActiveRecord::Migration[5.2]
  def change
    add_column :ecommerce_sales, :quotation_id, :integer
  end
end
