class AddInstalationToQuotationProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :quotation_products, :instalation, :boolean, default: false
  end
end
