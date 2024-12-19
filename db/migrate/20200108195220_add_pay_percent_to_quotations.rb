class AddPayPercentToQuotations < ActiveRecord::Migration[5.2]
  def change
    add_column :quotations, :pay_percent, :integer, default: 100
  end
end
