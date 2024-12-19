class AddBstockToQuotations < ActiveRecord::Migration[5.2]
  def change
    add_column :quotations, :bstock, :boolean, default: false
  end
end
