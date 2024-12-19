class AddAdmissionDateToDetailQuotationProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :detail_quotation_products, :admission_date, :date
  end
end
