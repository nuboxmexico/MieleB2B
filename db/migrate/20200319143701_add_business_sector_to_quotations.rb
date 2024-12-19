class AddBusinessSectorToQuotations < ActiveRecord::Migration[5.2]
  def change
    add_column :quotations, :business_sector, :string
  end
end
