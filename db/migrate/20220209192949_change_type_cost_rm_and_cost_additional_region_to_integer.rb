class ChangeTypeCostRmAndCostAdditionalRegionToInteger < ActiveRecord::Migration[5.2]
  def change
    change_column :project_installation_values, :cost_RM, :integer
    change_column :project_installation_values, :cost_additional_region, :integer
  end
end
