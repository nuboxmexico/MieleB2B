class AddRetirementDateToQuotations < ActiveRecord::Migration[5.2]
  def change
    add_column :quotations, :retirement_date, :date
  end
end
