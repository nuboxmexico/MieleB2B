class AddPercentageDiscountDispatchToQuotations < ActiveRecord::Migration[5.2]
  def change
    add_column :quotations, :percentage_discount_dispatch, :float
  end
end
