class ChangueTypeValuesToUnitRealState < ActiveRecord::Migration[5.2]
  def change
    change_column :unit_real_states, :unit_value, :float
    change_column :unit_real_states, :total_value, :float
  end
end
