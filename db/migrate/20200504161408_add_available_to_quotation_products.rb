class AddAvailableToQuotationProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :quotation_products, :available, :boolean, default: true
  end
end
