class AddInstallationValueToQuotations < ActiveRecord::Migration[5.2]
  def change
    add_column :quotations, :installation_value, :integer, default: 0
  end
end
