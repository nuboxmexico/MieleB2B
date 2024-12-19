class AddTotalToQuotations < ActiveRecord::Migration[5.2]
  def change
    add_column :quotations, :total, :integer
  end
end
