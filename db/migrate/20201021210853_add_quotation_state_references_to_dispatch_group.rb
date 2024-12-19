class AddQuotationStateReferencesToDispatchGroup < ActiveRecord::Migration[5.2]
  def change
    add_reference :dispatch_groups, :quotation_state, foreign_key: true
  end
end
