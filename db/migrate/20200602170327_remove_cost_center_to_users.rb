class RemoveCostCenterToUsers < ActiveRecord::Migration[5.2]
  def change
  	remove_column :users, :cost_center
  end
end
