class RemoveTypeAndNumberToUnitRealStates < ActiveRecord::Migration[5.2]
  def change
    remove_column :unit_real_states, :config_type, :string
    remove_column :unit_real_states, :config_number, :string
  end
end
