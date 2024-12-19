class AddInstallationSheetToDispatchGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :dispatch_groups, :installation_sheet, :string
  end
end
