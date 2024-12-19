class AddInstallationDateToDispatchGroup < ActiveRecord::Migration[5.2]
  def change
    add_column :dispatch_groups, :installation_date, :date
  end
end
