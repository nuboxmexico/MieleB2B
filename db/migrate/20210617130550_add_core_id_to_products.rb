class AddCoreIdToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :core_id, :bigint
  end
end
