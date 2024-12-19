class RemoveCostCenterToQuotations < ActiveRecord::Migration[5.2]
  def change
  	remove_column :quotations, :cost_center
  end
end
