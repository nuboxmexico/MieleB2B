class AddIsRmToUnitRealState < ActiveRecord::Migration[5.2]
  def change
    add_column :unit_real_states, :is_rm, :boolean
  end
end
