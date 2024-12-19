class ChangeQuotationReferenceToQuotation < ActiveRecord::Migration[5.2]
  def change
    rename_column :quotations, :quotation_id, :next_version_id
  end
end
