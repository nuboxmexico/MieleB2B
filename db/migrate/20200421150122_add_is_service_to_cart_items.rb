class AddIsServiceToCartItems < ActiveRecord::Migration[5.2]
  def change
    add_column :cart_items, :is_service, :boolean, default: false
    add_column :quotation_products, :is_service, :boolean, default: false
  end
end
