class AddCoreIdToQuotationProduct < ActiveRecord::Migration[5.2]
  def change
    add_column :quotation_products, :core_id, :bigint
    remove_column :quotation_products, :replicated_in_core
  end
end
