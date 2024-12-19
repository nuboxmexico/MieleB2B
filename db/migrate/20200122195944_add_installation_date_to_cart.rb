class AddInstallationDateToCart < ActiveRecord::Migration[5.2]
  def change
    add_column :quotations, :installation_date, :date
  end
end
