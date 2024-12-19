class AddDispatchInstalationHomeProramToDetailQuotationProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :detail_quotation_products, :dispatch, :boolean
    add_column :detail_quotation_products, :instalation, :boolean
    add_column :detail_quotation_products, :home_program, :boolean
  end
end
