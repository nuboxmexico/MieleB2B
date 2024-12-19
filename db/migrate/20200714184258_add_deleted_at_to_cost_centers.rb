class AddDeletedAtToCostCenters < ActiveRecord::Migration[5.2]
  def change
    add_column :cost_centers, :deleted_at, :datetime
    add_index :cost_centers, :deleted_at
  end
end
