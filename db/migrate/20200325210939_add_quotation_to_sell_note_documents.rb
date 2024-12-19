class AddQuotationToSellNoteDocuments < ActiveRecord::Migration[5.2]
  def change
    add_reference :sell_note_documents, :quotation, foreign_key: true
  end
end
