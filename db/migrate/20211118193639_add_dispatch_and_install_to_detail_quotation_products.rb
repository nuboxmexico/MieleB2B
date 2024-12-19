class AddDispatchAndInstallToDetailQuotationProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :detail_quotation_products, :dispatched, :boolean
    add_column :detail_quotation_products, :installed, :boolean
  end
end
