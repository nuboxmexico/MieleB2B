class AddQuotationToDispatchGuides < ActiveRecord::Migration[5.2]
  def change
    add_reference :dispatch_guides, :quotation, foreign_key: true
  end
end
