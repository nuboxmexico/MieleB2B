class RenameTableProjectInstalationValue < ActiveRecord::Migration[5.2]
  def change
    rename_table :project_instalation_values, :project_installation_values
  end
end
