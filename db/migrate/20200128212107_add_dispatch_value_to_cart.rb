class AddDispatchValueToCart < ActiveRecord::Migration[5.2]
  def change
    add_column :carts, :dispatch_value, :integer, default: 0
  end
end
