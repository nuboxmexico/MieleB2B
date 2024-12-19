class AddFieldsToCartItem < ActiveRecord::Migration[5.2]
  def change
    add_column :cart_items, :instalation, :boolean, default: true
    add_column :cart_items, :dispatch, :boolean, default: true
  end
end
