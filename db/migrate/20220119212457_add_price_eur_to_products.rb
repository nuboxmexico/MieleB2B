class AddPriceEurToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products , :price_eur, :float
  end
end
