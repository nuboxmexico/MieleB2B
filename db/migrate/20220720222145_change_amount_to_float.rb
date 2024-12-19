class ChangeAmountToFloat < ActiveRecord::Migration[5.2]
  def change
    change_column :payments, :ammount, :float
  end
end
