class AddPromotionalCodeToCart < ActiveRecord::Migration[5.2]
  def change
    add_reference :carts, :promotional_code, foreign_key: true
  end
end
