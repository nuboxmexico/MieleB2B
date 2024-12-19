class AddReplicatedInCoreToQuotationProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :quotation_products, :replicated_in_core, :boolean, null: false, default: false
    add_index :quotation_products, :replicated_in_core
  end
end
