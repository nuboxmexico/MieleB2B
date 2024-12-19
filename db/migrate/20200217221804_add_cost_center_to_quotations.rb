class AddCostCenterToQuotations < ActiveRecord::Migration[5.2]
  def change
    add_column :quotations, :cost_center, :string
  end
end
