class AddPartnerCommissionToQuotations < ActiveRecord::Migration[5.2]
  def change
    add_column :quotations, :partner_commission, :integer
  end
end
