class AddLeadReferenceToQuotation < ActiveRecord::Migration[5.2]
  def change
    add_reference :quotations, :lead, foreign_key: true
  end
end
