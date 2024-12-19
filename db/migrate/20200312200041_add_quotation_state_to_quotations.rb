class AddQuotationStateToQuotations < ActiveRecord::Migration[5.2]
  def change
    add_reference :quotations, :quotation_state, foreign_key: true
  end
end
