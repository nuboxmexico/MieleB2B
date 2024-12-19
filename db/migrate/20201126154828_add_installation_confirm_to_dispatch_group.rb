class AddInstallationConfirmToDispatchGroup < ActiveRecord::Migration[5.2]
  def change
    add_column :dispatch_groups, :installation_confirm, :integer, default: 0
  end
end
