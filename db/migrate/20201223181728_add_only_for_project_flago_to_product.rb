class AddOnlyForProjectFlagoToProduct < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :only_for_project, :boolean, default: false
  end
end
