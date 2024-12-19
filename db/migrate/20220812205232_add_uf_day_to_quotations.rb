class AddUfDayToQuotations < ActiveRecord::Migration[5.2]
  def change
    add_column :quotations, :uf_day, :float
  end
end
