class AddInstalationDateToDetailQuotationProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :detail_quotation_products, :instalation_date, :date
  end
end
