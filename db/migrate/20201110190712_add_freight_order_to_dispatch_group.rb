class AddFreightOrderToDispatchGroup < ActiveRecord::Migration[5.2]
  def change
    add_column :dispatch_groups, :freight_order, :string
  end
end
