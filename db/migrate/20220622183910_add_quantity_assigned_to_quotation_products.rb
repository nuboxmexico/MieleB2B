class AddQuantityAssignedToQuotationProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :quotation_products, :quantity_assigned, :integer
  end
end
