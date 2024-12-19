class AddCoreIdToCustomers < ActiveRecord::Migration[5.2]
  def change
    add_column :customers, :core_id, :bigint
  end
end
