class ChangeTypeCostProductToFloat < ActiveRecord::Migration[5.2]
  def change
    remove_column :products, :cost
    add_column :products, :cost, :float
  end
end
