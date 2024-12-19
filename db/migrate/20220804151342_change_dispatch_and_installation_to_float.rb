class ChangeDispatchAndInstallationToFloat < ActiveRecord::Migration[5.2]
  def change
    change_column :quotations, :dispatch_value, :float, default: 0
    change_column :quotations, :installation_value, :float, default: 0
  end
end
