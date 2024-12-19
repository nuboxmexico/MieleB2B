class AddCostCenterToUsers < ActiveRecord::Migration[5.2]
  def change
    add_reference :users, :cost_center, foreign_key: true
  end
end
