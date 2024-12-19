class AddIsForProductToPromotionalCodes < ActiveRecord::Migration[5.2]
  def change
    add_column :promotional_codes, :is_for_product, :boolean, default: false
  end
end
