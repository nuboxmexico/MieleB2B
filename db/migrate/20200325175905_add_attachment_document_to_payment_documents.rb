class AddAttachmentDocumentToPaymentDocuments < ActiveRecord::Migration[5.2]
  def self.up
    change_table :payment_documents do |t|
      t.attachment :document
    end
  end

  def self.down
    remove_attachment :payment_documents, :document
  end
end
