class AddActivationReadyToQuotationProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :quotation_products, :activation_ready, :boolean, default: false
  end
end
