class AddMandatoryToCartItems < ActiveRecord::Migration[5.2]
  def change
    add_column :cart_items, :mandatory, :boolean, default: false
  end
end
