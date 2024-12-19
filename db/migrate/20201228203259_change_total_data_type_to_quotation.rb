class ChangeTotalDataTypeToQuotation < ActiveRecord::Migration[5.2]
  def change
    change_column :quotations, :total, :float, default: 0
  end
end
