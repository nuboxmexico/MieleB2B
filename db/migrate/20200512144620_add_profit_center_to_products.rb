class AddProfitCenterToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :profit_center, :string
  end
end
