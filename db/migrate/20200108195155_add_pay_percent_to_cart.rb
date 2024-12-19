class AddPayPercentToCart < ActiveRecord::Migration[5.2]
  def change
    add_column :carts, :pay_percent, :integer, default: 100
  end
end
