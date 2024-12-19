class AddQuotationToBillingDocuments < ActiveRecord::Migration[5.2]
  def change
    add_reference :billing_documents, :quotation, foreign_key: true
  end
end
