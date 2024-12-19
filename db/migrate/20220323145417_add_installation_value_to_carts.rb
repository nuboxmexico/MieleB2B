class AddInstallationValueToCarts < ActiveRecord::Migration[5.2]
  def change
    add_column :carts, :installation_value, :integer, default: 0
  end
end
