class AddValidQuotationToQuotation < ActiveRecord::Migration[5.2]
  def change
    add_column :quotations, :valid_quotation, :boolean, default: false
  end
end
