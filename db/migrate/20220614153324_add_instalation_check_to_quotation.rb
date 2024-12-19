class AddInstalationCheckToQuotation < ActiveRecord::Migration[5.2]
  def change
    add_column :quotations, :instalation_check, :boolean
  end
end
