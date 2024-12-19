class AddLinkedMandatoryToCartItems < ActiveRecord::Migration[5.2]
  def change
    add_column :cart_items, :linked_mandatory, :boolean, default: false
  end
end
