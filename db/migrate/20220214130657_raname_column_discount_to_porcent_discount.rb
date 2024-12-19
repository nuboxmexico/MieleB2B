class RanameColumnDiscountToPorcentDiscount < ActiveRecord::Migration[5.2]
  def change
    rename_column :project_installation_discounts, :discount, :discount_percentage
 end
end
