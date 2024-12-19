class AddTypeAndNumberToUnitRealStates < ActiveRecord::Migration[5.2]
  def change
    add_column :unit_real_states, :config_type, :string
    add_column :unit_real_states, :config_number, :string
  end
end
