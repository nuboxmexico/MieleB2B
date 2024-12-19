class AddValuesToUnitRealState < ActiveRecord::Migration[5.2]
  def change
    add_column :unit_real_states, :unit_value, :integer
    add_column :unit_real_states, :total_value, :integer    
  end
end
