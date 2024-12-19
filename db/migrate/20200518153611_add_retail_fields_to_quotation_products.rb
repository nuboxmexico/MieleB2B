class AddRetailFieldsToQuotationProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :quotation_products, :packing, :integer
    add_column :quotation_products, :sku_model, :string
    add_column :quotation_products, :branch_number, :string
    add_column :quotation_products, :branch_name, :string
    add_column :quotation_products, :product_order, :integer
  end
end
