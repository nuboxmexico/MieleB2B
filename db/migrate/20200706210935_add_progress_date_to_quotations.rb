class AddProgressDateToQuotations < ActiveRecord::Migration[5.2]
  def change
    add_column :quotations, :progress_date, :date
  end
end
