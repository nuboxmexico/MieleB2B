class AddDetailsToQuotations < ActiveRecord::Migration[5.2]
  def change
    add_column :quotations, :exchange_rate_date, :datetime
    add_column :quotations, :exchange_rate, :float
  end
end
