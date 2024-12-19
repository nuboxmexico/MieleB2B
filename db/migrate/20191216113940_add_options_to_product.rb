class AddOptionsToProduct < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :mandatory, :boolean, default: false
    add_column :products, :dispatch, :boolean, default: false
  end
end
