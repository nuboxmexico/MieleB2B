class ChangeUnitPriceTypeToLeadProduct < ActiveRecord::Migration[5.2]
  def change
    change_column :lead_products, :unit_price, :float
  end
end
