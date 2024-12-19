class AddCostCenterRelationToQuotations < ActiveRecord::Migration[5.2]
  def change
    add_reference :quotations, :cost_center, foreign_key: true
  end
end
