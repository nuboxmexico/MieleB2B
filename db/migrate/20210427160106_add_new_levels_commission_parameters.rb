class AddNewLevelsCommissionParameters < ActiveRecord::Migration[5.2]
  def change
    add_column :commission_parameters, :level_d, :integer
    add_column :commission_parameters, :level_e, :integer
  end
end
