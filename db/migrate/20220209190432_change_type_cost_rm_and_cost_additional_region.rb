class ChangeTypeCostRmAndCostAdditionalRegion < ActiveRecord::Migration[5.2]
  def change
    change_column :project_instalation_values, :cost_RM, :float
    change_column :project_instalation_values, :cost_additional_region, :float
  end
end
