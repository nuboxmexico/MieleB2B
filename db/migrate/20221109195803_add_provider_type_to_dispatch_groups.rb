class AddProviderTypeToDispatchGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :dispatch_groups, :provider_type, :string
  end
end
