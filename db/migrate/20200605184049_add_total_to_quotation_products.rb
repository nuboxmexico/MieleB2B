class AddTotalToQuotationProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :quotation_products, :total, :integer
  end
end
