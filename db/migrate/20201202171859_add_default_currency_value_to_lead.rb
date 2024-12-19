class AddDefaultCurrencyValueToLead < ActiveRecord::Migration[5.2]
  def change
    change_column :leads, :currency, :integer, default: 0
  end
end
