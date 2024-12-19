class AddAttachmentDocumentToQuotationDocuments < ActiveRecord::Migration[5.2]
  def self.up
    change_table :quotation_documents do |t|
      t.attachment :document
    end
  end

  def self.down
    remove_attachment :quotation_documents, :document
  end
end
