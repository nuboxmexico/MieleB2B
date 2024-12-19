class AddQuotationToPaymentDocuments < ActiveRecord::Migration[5.2]
  def change
    add_reference :payment_documents, :quotation, foreign_key: true
  end
end
