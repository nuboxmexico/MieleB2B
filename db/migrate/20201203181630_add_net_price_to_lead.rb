class AddNetPriceToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :net_price, :float
  end
end
