class AddBstockFieldsToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :bstock, :boolean, default: false
    add_column :products, :ean, :string
    add_reference :products, :cost_center, foreign_key: true
    add_column :products, :category, :string
    add_column :products, :state, :string
  end
end
