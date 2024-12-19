class AddExpirationDateToQuotations < ActiveRecord::Migration[5.2]
  def change
    add_column :quotations, :expiration_date, :date
  end
end
