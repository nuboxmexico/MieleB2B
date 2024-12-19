class AddDefaultFieldsQuotations < ActiveRecord::Migration[5.2]
  def change
  	change_column :quotations, :dispatch_value, :integer, default: 0
  	change_column :quotations, :total, :integer, default: 0
  end
end
