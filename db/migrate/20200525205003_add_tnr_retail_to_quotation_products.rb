class AddTnrRetailToQuotationProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :quotation_products, :tnr_retail, :string
  end
end
