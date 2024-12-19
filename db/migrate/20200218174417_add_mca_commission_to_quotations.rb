class AddMcaCommissionToQuotations < ActiveRecord::Migration[5.2]
  def change
    add_column :quotations, :mca_commission, :integer, default: 0
  end
end
